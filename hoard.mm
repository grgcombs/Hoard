#include "hoard.h"
#include <vector>
#include <algorithm>
#include <tr1/functional>

// ### Constructors and Destructors
hoard::hoard(id *input, NSUInteger size) {
  storage = [[NSArray alloc] initWithObjects:input count:size];
}

hoard::hoard(NSArray *arr) {
  storage = [[NSArray alloc] initWithArray:arr];
}

hoard::hoard(NSSet *set) {
  storage = [set.allObjects copy];
}

hoard::hoard(NSDictionary *dict) {
  NSUInteger count = dict.allKeys.count;
  
  id keys[count];
  id objects[count];
  
  [dict getObjects:objects andKeys:keys];
  
  id interpolated[count*2];
  for (int i = 0; i < count; i = i++) {
    interpolated[2*i] = keys[i];
    interpolated[2*i+1] = objects[i];
  }
  
  hoard(interpolated,count*2);
}

hoard::hoard(hoard::Vector vec) {
  NSMutableArray *a = [NSMutableArray arrayWithCapacity:vec.size()];
  std::for_each(vec.begin(), vec.end(), ^(id o) {
    [a addObject:o];
  });
  
  hoard(static_cast<NSArray*>(a));
}

hoard::hoard(hoard::TupleVector vec) {
  hoard::Vector dest(vec.size() * 2);
  
  for (int i = 0; i < vec.size(); i++) {
    hoard::Tuple t = vec[i];
    dest[2*i] = std::tr1::get<0>(vec[i]);
    dest[2*i+1] = std::tr1::get<1>(vec[i]);
  }
  
  hoard(static_cast<hoard::Vector>(dest));
}

hoard::~hoard() {
  [storage release];
}


// ### Array Subscript Operator
id hoard::operator[](NSUInteger i) const {
  return [get<NSArray*>() objectAtIndex:i];
}

hoard hoard::operator[](NSRange r) const {
  id indexes = [NSIndexSet indexSetWithIndexesInRange:r];
  return hoard([get<NSArray*>() objectsAtIndexes:indexes]);
}

NSIndexSet *hoard::operator[](id o) const {
  id pred = ^(id obj, ...) { return [obj isEqual:o]; };
  return [get<NSArray*>() indexesOfObjectsPassingTest:pred];
}

// ### Extracting Collections
template <> NSArray *hoard::get<NSArray*>() const {
  return [NSArray arrayWithArray:storage];
}

template <> NSSet *hoard::get<NSSet*>() const {
  return [NSSet setWithArray:storage];
}

template <> NSDictionary *hoard::get<NSDictionary*>() const {
  NSUInteger half = storage.count / 2;
  id keys[half];
  id objs[half];
  
  for (NSUInteger i = 0; i < half; i++) {
    keys[i] = [storage objectAtIndex:i * 2];
    objs[i] = [storage objectAtIndex:i * 2 + 1];
  }
  
  return [NSDictionary dictionaryWithObjects:objs forKeys:keys count:half];
}

template <> hoard::Vector hoard::get<hoard::Vector>() const {
  hoard::Vector vec(storage.count);
  
  for (id obj in storage) {
    vec.push_back(obj);
  }
  
  return vec;
}

template <> hoard::TupleVector hoard::get<hoard::TupleVector>() const {
	NSDictionary *dict = get<NSDictionary*>();
	hoard::TupleVector vec(dict.allKeys.count);
	
	for (id key in dict) {
		vec.push_back(hoard::Tuple(key, [dict objectForKey:key]));
	}

	return vec;
}


hoard::operator id <NSFastEnumeration> () const {
  return get<NSArray*>();
}

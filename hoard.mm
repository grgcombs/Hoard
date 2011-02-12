#include "hoard.h"
#include <vector>
#include <algorithm>
#include <tr1/functional>

// ### Constructors and Destructors
hoard::hoard(id *input, NSUInteger size) {
  storage = [[NSArray arrayWithObjects:input count:size] retain];
}

hoard::hoard(NSArray *arr) {
  storage = [arr retain];
}

hoard::hoard(NSSet *set) {
  storage = [set.allObjects retain];
}

hoard::hoard(NSDictionary *dict) {
  NSUInteger count = dict.count;
  
  id keys[count];
  id objects[count];
  id interpolated[count*2];
  
  [dict getObjects:objects andKeys:keys];
  
  for (int i = 0; i < count; i = i++) {
    interpolated[2*i] = keys[i];
    interpolated[2*i+1] = objects[i];
  }
  
  hoard(interpolated,count*2);
}

hoard::hoard(std::vector<id> vec) {
  NSMutableArray *a = [NSMutableArray arrayWithCapacity:vec.size()];
  std::for_each(vec.begin(), vec.end(), ^(id o) {
    [a addObject:o];
  });
  
  hoard(static_cast<NSArray*>(a));
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
  
  for(NSUInteger i = 0; i < half; i++) {
    keys[i] = [storage objectAtIndex:i * 2];
    objs[i] = [storage objectAtIndex:i * 2 + 1];
  }
  
  return [NSDictionary dictionaryWithObjects:objs forKeys:keys count:half];
}

template <> std::vector<id> hoard::get<std::vector<id> >() const {
  std::vector<id> vec(storage.count);
  for (int i = 0; i < storage.count; i++) {
    vec[i] = [storage objectAtIndex:i];
  }
  
  return vec;
}

hoard::operator id <NSFastEnumeration> () const {
  return get<NSArray*>();
}
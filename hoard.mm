#import "hoard.h"
#import "metamadness.h"
#import "conversion_madness.h"
#import <algorithm>
#import <tr1/functional>
  
template <class C, class E>
void addToCollection(C collection, E object) {
  [collection addObject:object];
}

template <>
void addToCollection(NSMutableDictionary *collection, hoard::Pair obj) {
  [collection setValue:obj.second forKey:obj.first];
}

template <class C, class B, class E> hoard hoardFromCollection(C coll, B buffer) {
  using namespace std::tr1;
  
  function<void(B,E)> filler = addToCollection<B,E>;
  for_each(coll.begin(), coll.end(), bind1st(filler, buffer));
  
  return hoard(static_cast<typename immutable_variant<B>::type>(buffer));
}

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

// #### STL constructors
hoard::hoard(hoard::Vector vec) {
  id buff = [NSMutableArray arrayWithCapacity:vec.size()];
  hoardFromCollection<hoard::Vector,NSMutableArray*,id>(vec,buff);
}

hoard::hoard(hoard::Set set) {
  id buff = [NSMutableSet setWithCapacity:set.size()];
  hoardFromCollection<hoard::Set,NSMutableSet*,id>(set,buff);
}

hoard::hoard(hoard::Map map) {
  id buff = [NSMutableDictionary dictionaryWithCapacity:map.size()];
  hoardFromCollection<hoard::Map,NSMutableDictionary*,hoard::Pair>(map, buff);
}

hoard::~hoard() {
  [storage release];
}


// ### Array Subscript Operator
id hoard::operator[](NSUInteger i) const {
  return [as<NSArray*>() objectAtIndex:i];
}

hoard hoard::operator[](NSRange r) const {
  id indexes = [NSIndexSet indexSetWithIndexesInRange:r];
  return hoard([as<NSArray*>() objectsAtIndexes:indexes]);
}

NSIndexSet *hoard::operator[](id o) const {
  id pred = ^(id obj, ...) { return [obj isEqual:o]; };
  return [as<NSArray*>() indexesOfObjectsPassingTest:pred];
}

// ### Manifesting Collections

hoard::operator id <NSFastEnumeration> () const {
  return as<NSArray*>();
}

template <> NSArray *hoard::as<NSArray*>() const {
  return [NSArray arrayWithArray:storage];
}

template <> NSSet *hoard::as<NSSet*>() const {
  return [NSSet setWithArray:storage];
}

template <> NSDictionary *hoard::as<NSDictionary*>() const {
  NSUInteger half = storage.count / 2;
  id keys[half];
  id objs[half];
  
  for (NSUInteger i = 0; i < half; i++) {
    keys[i] = [storage objectAtIndex:i * 2];
    objs[i] = [storage objectAtIndex:i * 2 + 1];
  }
  
  return [NSDictionary dictionaryWithObjects:objs forKeys:keys count:half];
}

template <> hoard::Vector hoard::as<hoard::Vector>() const {
  hoard::Vector vec(storage.count);
  for (id obj in storage) { vec.push_back(obj); }
  
  return vec;
}

template <> hoard::Set hoard::as<hoard::Set>() const {
  hoard::Set set;
  for (id obj in storage) { set.insert(obj); }
  
  return set;
}

template <> hoard::Map hoard::as<hoard::Map>() const {
  id dict = as<NSDictionary*>();
  
  hoard::Map map;
  for (id key in dict) {
    map[key] = [dict objectForKey:key];
  }
  
  return map;
}

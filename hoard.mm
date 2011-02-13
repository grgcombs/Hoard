#import "hoard.h"
#import "metamadness.h"
#import <algorithm>
#import <tr1/functional>

template <typename C,typename E=id>
struct CollectionFiller : public std::unary_function<id,void> {
public:
  C collection;
  CollectionFiller(C c) : collection(c) {}
  void operator()(E obj) {
    [collection addObject:obj];
  }
};

template <>
void CollectionFiller<NSMutableDictionary *,hoard::Pair>::operator()(hoard::Pair obj) {
  [collection setValue:obj.second forKey:obj.first];
}
  

template <class C, class B, class E> hoard hoardFromCollection(C coll, B buffer) {
  CollectionFiller<B,E> filler(buffer);
  std::for_each(coll.begin(), coll.end(), filler);
  
  typedef typename immutable_variant<B>::T IC;
  return hoard(static_cast<IC>(buffer));
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

// ### Manifesting Collections

hoard::operator id <NSFastEnumeration> () const {
  return get<NSArray*>();
}

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
  for (id obj in storage) { vec.push_back(obj); }
  
  return vec;
}

template <> hoard::Set hoard::get<hoard::Set>() const {
  hoard::Set set;
  for (id obj in storage) { set.insert(obj); }
  
  return set;
}

template <> hoard::Map hoard::get<hoard::Map>() const {
  id dict = get<NSDictionary*>();
  
  hoard::Map map;
  for (id key in dict) {
    map[key] = [dict objectForKey:key];
  }
  
  return map;
}


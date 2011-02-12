#include "hoard.h"
#include <vector>


// ## Constructors and Destructors
hoard::hoard(id *input, NSUInteger size) {
  storage = [[NSArray arrayWithObjects:input count:size] retain];
}

hoard::hoard(NSArray *arr) {
  storage = [arr retain];
}

hoard::~hoard() {
  [storage release];
}


// ## Array Subscript Operator
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


// ## Casting to `id`
hoard::operator id <NSFastEnumeration> () const {
  return get<NSArray*>();
}

// ## Extracting Collections
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
#include "hoard.h"
#include <vector>

hoard::operator id <NSFastEnumeration> () const {
  return get<NSArray*>();
}

id hoard::operator[](NSUInteger i) const {
  return [get<NSArray*>() objectAtIndex:i];
}

id hoard::operator[](NSRange r) const {
  id indexes = [NSIndexSet indexSetWithIndexesInRange:r];
  return [get<NSArray*>() objectsAtIndexes:indexes];
}

NSIndexSet *hoard::operator[](id o) const {
  id pred = ^(id obj, ...) { return [obj isEqual:o]; };
  return [get<NSArray*>() indexesOfObjectsPassingTest:pred];
}


template <> std::vector<id> extract<std::vector<id> >(const id *objects, NSUInteger count) {
  return std::vector<id>(objects,objects + count);
}

template <> NSArray *extract<NSArray*>(const id *objects, NSUInteger count) {
  return [NSArray arrayWithObjects:objects count:count];
}

template <> NSSet *extract<NSSet*>(const id *objects, NSUInteger count) {
  return [NSSet setWithObjects:objects count:count];
}

template <> NSDictionary *extract<NSDictionary*>(const id *objects, NSUInteger count) {
  id keys[count/2];
  id objs[count/2];
  
  for(NSUInteger i = 0; i < count/2; i++) {
    keys[i] = objects[i * 2];
    objs[i] = objects[i * 2 + 1];
  }
  
  return [NSDictionary dictionaryWithObjects:objs forKeys:keys count:count/2];
}
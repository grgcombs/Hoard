#define hd_IDCOUNT(...) (sizeof(hd_IDARRAY(__VA_ARGS__)) / sizeof(id))
#define hd_IDARRAY(...) (id []){ __VA_ARGS__ }
#define hd(...) hoard(hd_IDARRAY(__VA_ARGS__),hd_IDCOUNT(__VA_ARGS__));

template <class T> T* extract(const id *objects, NSUInteger count);

struct hoard {
  hoard(id *input,NSUInteger size) : storage(input), size(size) {};
  
  id operator[](NSUInteger i) const;
  id operator[](NSRange r) const;
  NSIndexSet *operator[](id o) const;
  
  operator id <NSFastEnumeration> () const;
  
  template <class T> T* get() const {
    return extract<T>(storage,size);
  }
  
private:
  NSUInteger size;
  const id *storage;
};


hoard::operator id <NSFastEnumeration> () const {
  return get<NSArray>();
}

id hoard::operator[](NSUInteger i) const {
  return [get<NSArray>() objectAtIndex:i];
}

id hoard::operator[](NSRange r) const {
  id indexes = [NSIndexSet indexSetWithIndexesInRange:r];
  return [get<NSArray>() objectsAtIndexes:indexes];
}

NSIndexSet *hoard::operator[](id o) const {
  id pred = ^(id obj, ...) { return [obj isEqual:o]; };
  return [get<NSArray>() indexesOfObjectsPassingTest:pred];
}


template <> NSArray *extract<NSArray>(const id *objects, NSUInteger count) {
  return [NSArray arrayWithObjects:objects count:count];
}

template <> NSSet *extract<NSSet>(const id *objects, NSUInteger count) {
  return [NSSet setWithObjects:objects count:count];
}

template <> NSDictionary *extract<NSDictionary>(const id *objects, NSUInteger count) {
  id keys[count];
  id objs[count];
  
  for(NSUInteger i = 0; i < count; i++) {
    keys[i] = objects[i * 2];
    objs[i] = objects[i * 2 + 1];
  }
  
  return [NSDictionary dictionaryWithObjects:objs forKeys:keys count:count/2];
}
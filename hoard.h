#import <vector>

#define hd_IDCOUNT(...) (sizeof(hd_IDARRAY(__VA_ARGS__)) / sizeof(id))
#define hd_IDARRAY(...) (id []){ __VA_ARGS__ }
#define hd(...) hoard(hd_IDARRAY(__VA_ARGS__),hd_IDCOUNT(__VA_ARGS__));

template <class T> T extract(const id *objects, NSUInteger count);

struct hoard {
  hoard(id *input,NSUInteger size) : storage(input), size(size) {};
  
  id operator[](NSUInteger i) const;
  id operator[](NSRange r) const;
  NSIndexSet *operator[](id o) const;
  
  operator id <NSFastEnumeration> () const;
  
  template <class T> T get() const {
    return extract<T>(storage,size);
  }
      
private:
  NSUInteger size;
  const id *storage;
};
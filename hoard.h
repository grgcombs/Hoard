#import <vector>

// `hoard` is a safe and convenient wrapper around Cocoa collections. You create
// a `hoard` using the `hd` macro:
//
//     hoard col = hd(@"dogs",@"are",@"the",@"best!");
// 
// It is necessary to use the C preprocessor in order to avoid explicit mention
// of the number of items in the collection. The preprocessor can splice the
// items into an array, count them, and then send them to our constructor.
#define hd(...) hoard(hd_IDARRAY(__VA_ARGS__),hd_IDCOUNT(__VA_ARGS__));
#define hd_IDCOUNT(...) (sizeof(hd_IDARRAY(__VA_ARGS__)) / sizeof(id))
#define hd_IDARRAY(...) (id []){ __VA_ARGS__ }

struct hoard {
  hoard(id *input, NSUInteger size);
  hoard(NSArray *arr);
  ~hoard();
  
  // The `[]` operator has been overloaded a few times. The first and presumably
  // most useful is the one that takes an integer: `h[i]` will return the `i`th
  // term in a `hoard`. Note that `hoard`s are not manifested as a Cocoa
  // collection until you ask them to be; using array subscripts like this will
  // cause your `hoard` to be treated as an array.
  id operator[](NSUInteger i) const;

  hoard operator[](NSRange r) const;
  NSIndexSet *operator[](id o) const;
  
  operator id <NSFastEnumeration> () const;
  
  template <class T> T get() const;
      
private:
  NSArray *storage;
};

template <> NSArray *hoard::get<NSArray*>() const;
template <> NSSet *hoard::get<NSSet*>() const;
template <> NSDictionary *hoard::get<NSDictionary*>() const;
template <> std::vector<id> hoard::get<std::vector<id> >() const;
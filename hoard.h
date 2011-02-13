#import <vector>
#import <tr1/tuple>

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
  typedef std::tr1::tuple<id,id> Tuple;
  typedef std::vector<Tuple> TupleVector;
  typedef std::vector<id> Vector;

  hoard(id *input, NSUInteger size);
  hoard(NSArray *arr);
  hoard(NSSet *set);
  hoard(NSDictionary *dict);
  hoard(hoard::Vector vec);
  hoard(hoard::TupleVector vec);
  ~hoard();
  
  // The `[]` operator has been overloaded a few times. The first and presumably
  // most useful is the one that takes an integer: `h[i]` will return the `i`th
  // term in a `hoard`. Note that `hoard`s are not manifested as a Cocoa
  // collection until you ask them to be; using array subscripts like this will
  // cause your `hoard` to be treated as an array.
  id operator[](NSUInteger i) const;
  
  // You can also take a slice of a hoard by passing an `NSRange` into
  // `operator[]`. This will return a new `hoard`. This means that something
  // like the following is possible:
  // 
  //     NSRange rn = NSMakeRange(0,2);
  //     id arr = col[rn]; // => [@"dogs",@"are"]
  //     id obj = col[rn][0]; // => @"dogs"
  // 
  //
  hoard operator[](NSRange r) const;

  // Finally, you can also find all the indices at which an object occurs by
  // passing it into `operator[]`.
  NSIndexSet *operator[](id o) const;
  
  // The default cast operator will yield an object that is guaranteed to
  // conform to `<NSFastEnumeration>`; this is useful for `for`-loops. For more
  // specific conversions, use `get<T>`.
  operator id <NSFastEnumeration> () const;
  
  // Using `get<T>`, you can convert the hoard into one of the Cocoa
  // collections (and `std::vector` as well):
  //
  //     id arr = col.get<NSArray*>(); // the same as the underlying form
  //     id set = col.get<NSSet*>(); // order is now irrelevant
  //     id dict = col.get<NSDictionary*>(); // groups elements by twos
  //     std::vector<id> vec = col.get<std::vector<id>>();
  template <class T> T get() const;
      
private:
  NSArray *storage;
};

template <> NSArray *hoard::get<NSArray*>() const;
template <> NSSet *hoard::get<NSSet*>() const;
template <> NSDictionary *hoard::get<NSDictionary*>() const;
template <> hoard::Vector hoard::get<hoard::Vector>() const;
template <> hoard::TupleVector hoard::get<hoard::TupleVector>() const;
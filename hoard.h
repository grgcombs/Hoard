#import <vector>
#import <set>
#import <map>
#import <algorithm>
#import "metamadness.h"

// `hoard` is a safe and convenient wrapper around Cocoa collections. You create
// a `hoard` using the `hd` macro:
//
//     hoard col = hd(@"dogs",@"are",@"the",@"best!");
// 
// It is necessary to use the C preprocessor in order to avoid explicit mention
// of the number of items in the collection. The preprocessor can splice the
// items into an array, count them, and then send them to our constructor.
// 
// For now, the type inference capabilities of `hd` are such that when your
// individual elements are arrays themselves, it will *not* work properly. In
// this case, use the `hdT` macro:
//
//     hoard char_arrays = hdT(const char*,"testing","wut");
//

#define hd(first,args...)\
  hdT(typeof(first),first,args)

#define hdT(T,first,args...) ({\
    T arr[] = { (first), args };\
    size_t sz = sizeof(arr)/sizeof(T);\
    hoard::hoardT<T>(arr,sz);\
});

struct hoard {
  typedef std::vector<id> Vector;
  typedef std::set<id> Set;
  typedef std::map<id,id> Map;
  typedef Map::value_type Pair;

  hoard(id *input, NSUInteger size);
  hoard(NSArray *arr);
  hoard(NSSet *set);
  hoard(NSDictionary *dict);
  hoard(Vector vec);
  hoard(Set set);
  hoard(Map vec);
  
  ~hoard();
  
  // A `hoard` can also be constructed from a C array of some type `T`.
  template <class T>
  static hoard hoardT(T *input, NSUInteger size);
  
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
  
  // Using `get<T>`, you can manifest the hoard as one of several collection
  // types.
  template <class T> T get() const;
        
private:
  NSArray *storage;
};

// To manifest the `hoard` as one of the supported Cocoa collections, use
//
//     T *output = col.get<T*>();
//
// where *T* ∈ {`NSArray`,`NSSet`,`NSDictionary`}.
template <> NSArray *hoard::get<NSArray*>() const;
template <> NSSet *hoard::get<NSSet*>() const;
template <> NSDictionary *hoard::get<NSDictionary*>() const;

// It's also possible to manifest a hoard as an STL collection.
//
//     std::vector<id> vec = col.get<std::vector<id> >();
//     std::map<id,id> map = col.get<std::map<id,id> >();
//
// can be shortened to the following using the `hoard::*` type synonyms.
//
//     hoard::Vector vec = col.get<hoard::Vector>();
//     hoard::Map map = col.get<hoard::Map>();
//
template <> hoard::Vector hoard::get<hoard::Vector>() const;
template <> hoard::Set hoard::get<hoard::Set>() const;
template <> hoard::Map hoard::get<hoard::Map>() const;

template <class I, class O>
O convert(I);

template <class T>
hoard hoard::hoardT(T *input, NSUInteger size) {
  id boxed[size];
  
  typedef typename upcast_if_possible<T,id>::type U;
  
  for (int i = 0; i < size; i++) {
    boxed[i] = convert<U,id>(input[i]);
  }
  
  return hoard(boxed,size);
}

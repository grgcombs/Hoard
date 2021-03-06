#import <tr1/type_traits>

// `immutable_variant` is a metafunction which takes a Cocoa collection type and
// tries to return the immutable version of that type. For example,
//
//     immutable_variant<NSMutableArray*>::type ↦ NSArray.
//
template <class T>
struct immutable_variant;

// `type_if` is a static conditional which decides between two types `L,R` at
// compile-time based on boolean `B`. For example, 
//
//     type_if<const char*,std::string,false>::type ↦ std::string.
//
template <class L, class R, bool B>
struct type_if;

// If type `I` is convertible into type `O`, `upcast_if_possible` will return
// `O`, otherwise `I`. For example,
//
//     upcast_if_possible<NSString*,id>::type ↦ id.
//     upcast_if_possible<NSString*,std::String>::type ↦ NSString*.
//
template <class I, class O>
struct upcast_if_possible {
  typedef typename type_if<O,I,std::tr1::is_convertible<I,O>::value>::type type;
};


#pragma mark -
#pragma mark Specializations

template <>
struct immutable_variant<NSMutableArray*> {
  typedef NSArray *type;
};

template <>
struct immutable_variant<NSMutableSet*> {
  typedef NSSet *type;
};

template <>
struct immutable_variant<NSMutableDictionary*> {
  typedef NSDictionary *type;
};

template <class L, class R>
struct type_if<L,R,true> {
  typedef L type;
};

template <class L, class R>
struct type_if<L,R,false> {
  typedef R type;
};




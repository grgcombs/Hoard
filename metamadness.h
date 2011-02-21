#import <tr1/type_traits>

using namespace std::tr1;

// `immutable_variant` is a metafunction which takes a Cocoa collection type and
// tries to return the immutable version of that type. For example,
//
//     immutable_variant<NSMutableArray*>::T ↦ NSArray.
//
template <class T>
struct immutable_variant;

// `type_if` is a static conditional which decides between two types `T,S` at
// compile-time based on boolean `B`. For example, 
//
//     type_if<const char*,std::string,false>::type ↦ std::string.
//
template <class T, class S, bool B>
struct type_if;

// If type `I` is convertible into type `O`, `upcast_if_possible` will return
// `O`, otherwise `I`. For example,
//
//     upcast_if_possible<NSString*,id>::type ↦ id.
//     upcast_if_possible<NSString*,std::String>::type ↦ NSString*.
//
template <class I, class O>
struct upcast_if_possible {
  typedef typename type_if<O,I,is_convertible<I,O>::value>::type type;
};


#pragma mark -
#pragma mark Specializations

template <>
struct immutable_variant<NSMutableArray*> {
  typedef NSArray *T;
};

template <>
struct immutable_variant<NSMutableSet*> {
  typedef NSSet *T;
};

template <>
struct immutable_variant<NSMutableDictionary*> {
  typedef NSDictionary *T;
};

template <class T, class S>
struct type_if<T,S,true> {
  typedef T type;
};

template <class T, class S>
struct type_if<T,S,false> {
  typedef S type;
};




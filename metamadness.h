#import <tr1/type_traits>

using namespace std::tr1;

template <class T>
struct immutable_variant;

template <class T, class S, bool B>
struct type_if;

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




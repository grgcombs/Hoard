#import <tr1/type_traits>

template <class T>
struct immutable_variant;

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


template <class T, class S, bool B>
struct type_if;

template <class T, class S>
struct type_if<T,S,true> {
  typedef T type;
};

template <class T, class S>
struct type_if<T,S,false> {
  typedef S type;
};



template <class I, class O>
struct upcast_if_possible {
  typedef typename type_if<O,I,std::tr1::is_convertible<I,O>::value>::type type;
};
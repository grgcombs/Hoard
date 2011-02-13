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
#import <string>

template <class I, class O>
O convert(I input);

template <>
id convert(id input) {
  return input;
}

template <>
const char *convert(NSString *input) {
  return [input UTF8String];
}

template <>
id convert(const char *input) {
  return [NSString stringWithUTF8String:input];
}

template <>
std::string convert(NSString *input) {
  return std::string([input UTF8String]);
}

template <>
id convert(std::string input) {
  return [NSString stringWithUTF8String:input.c_str()];
}

template <>
int convert(NSNumber *input) {
  return [input intValue];
}

template <>
id convert(int input) {
  return [NSNumber numberWithInt:input];
}

template <>
unsigned int convert(NSNumber *input) {
  return [input unsignedIntValue];
}

template <>
id convert(NSUInteger input) {
  return [NSNumber numberWithUnsignedInteger:input];
}

template <>
float convert(NSNumber *input) {
  return [input floatValue];
}

template <>
id convert(float input) {
  return [NSNumber numberWithFloat:input];
}

template <>
BOOL convert(NSNumber *input) {
  return [input boolValue];
}

template <>
id convert(BOOL input) {
  return [NSNumber numberWithBool:input];
}
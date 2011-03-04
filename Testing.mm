#import <Foundation/Foundation.h>
#import "hoard.h"

int main (int argc, const char * argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  hoard int_array = hd(1,1,2,3,5,8,13);
  NSLog(@"ints: %@", int_array.as<NSArray*>());
  
  hoard cstring_array = hdT(const char*, "sdsf","sdb","asdf","fasdf","dsf");
  NSLog(@"cstrings: %@", cstring_array.as<NSArray*>());
  
  hoard strings_array = hd(@"asdfadsf",@"asdfadsf",@"asdf");
  NSLog(@"nsstrings: %@", strings_array.as<NSArray*>());
  
  [pool drain];
  return 0;
}
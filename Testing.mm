#import <Foundation/Foundation.h>
#import "hoard.h"

int main (int argc, const char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  hoard h = hd(@"a",@"b",@"c");
  NSLog(@"hoard: %@", (id)h);
  NSLog(@"second object: %@", h[1]);
  
  for (id o in (id)h) {
    NSLog(@"object: %@", o);
  }
  
  hoard dict = hd(@"key",@"value");
  NSLog(@"dict: %@", dict.get<NSDictionary*>());
  
  [pool drain];
  return 0;
}

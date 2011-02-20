#import <Foundation/Foundation.h>
#import "hoard.h"
#import <string>
#import <vector>

int main (int argc, const char * argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  hoard prim = hd("asdf","asdf");
  NSLog(@"prim: %@", prim.get<NSDictionary*>());
  
  [pool drain];
  return 0;
}

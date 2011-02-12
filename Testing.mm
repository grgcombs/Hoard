#import <Foundation/Foundation.h>
#import "hoard.h"

int main (int argc, const char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  hoard h = hd(@"a",@"b",@"c",@"d",@"f");
  NSRange r = NSMakeRange(0, 3);
  NSLog(@"test range: %@", (id)h[r]);
  
  hoard dict = hd(@"key",@"value",@"key2",@"value2");
  NSLog(@"dict: %@", dict.get<NSDictionary*>());
  
  [pool drain];
  return 0;
}

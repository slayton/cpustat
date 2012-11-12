#import "TaskInfo.h"
@implementation TaskInfo

@synthesize name;
@synthesize cpu;
@synthesize ram;
@synthesize pid;

-(id) initWithName:(NSString*)n percentCpu:(double)c percentRam:(double) r andPID:(int)p{
    
    self = [super init];
    if(self){
        self.name = n;
        self.cpu = c;
        self.ram = r;
        self.pid = p;
    }
    
    return self;
}



@end

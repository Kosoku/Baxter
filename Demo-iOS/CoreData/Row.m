#import "Row.h"
#import "LoremIpsum.h"

#import <Baxter/Baxter.h>
#import <Stanley/Stanley.h>

@interface Row ()

// Private interface goes here.

@end

@implementation Row

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    self.createdAt = NSDate.date;
    self.identifier = NSUUID.UUID.UUIDString;
    self.title = LoremIpsum.title;
    self.summary = LoremIpsum.sentence;
}

+ (NSFetchRequest *)fetchRequestForRowsSortedByCreatedAt {
    NSDictionary *options = @{KBANSFetchRequestOptionsKeyEntityName: [self entityName],
                              KBANSFetchRequestOptionsKeySortDescriptors: @[[NSSortDescriptor sortDescriptorWithKey:@kstKeypath(Row.new,createdAt) ascending:NO]]
                              };
    
    return [NSFetchRequest KBA_fetchRequestWithOptions:options];
}

@end

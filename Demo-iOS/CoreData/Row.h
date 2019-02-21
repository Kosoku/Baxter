#import "_Row.h"

@interface Row : _Row

@property (class,readonly,nonatomic) NSFetchRequest *fetchRequestForRowsSortedByCreatedAt;

@end

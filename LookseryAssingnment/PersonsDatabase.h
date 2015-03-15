//
//  PersonsDatabase.h
//  LookseryAssingnment
//
//  Created by Valeriy Van on 09.03.15.
//  Copyright (c) 2015 looksery.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class Person;

@interface PersonsDatabase : NSObject {
	sqlite3 *database;
}
+(instancetype)singleton;
-(id)initWithDataBaseFileName:(NSString*)filename;

-(BOOL)addPerson:(Person*)person;  // TODO: для анимации вставки в таблицу надо бы возвращать индекс вставленной записи (обновлять identifier?).
-(BOOL)updatePerson:(Person*)person;

-(unsigned long)personsCount;
-(Person*)personWithOffset:(unsigned long)offset; // nil означает ошибку

@end

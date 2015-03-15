//
//  PersonsDatabase.m
//  LookseryAssingnment
//
//  Created by Valeriy Van on 09.03.15.
//  Copyright (c) 2015 looksery.com. All rights reserved.
//

#import "PersonsDatabase.h"
#import "sqlite3_unicode.h"
#import "Person.h"

NSString *const kDatabaseFilename = @"assignmentappdb";
NSString *const kDatabaseExtention = @"sqlite3";
const CGFloat kCompressionQuality = 0.9;

#define DEBUG_TRACE NO

@interface PersonsDatabase ()
@end

static PersonsDatabase *_singleton = nil;

@implementation PersonsDatabase

+(instancetype)singleton {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filename = [kDatabaseFilename stringByAppendingPathExtension:kDatabaseExtention];
        NSString *pathname = [paths[0] stringByAppendingPathComponent:filename];
        _singleton = [[PersonsDatabase alloc] initWithDataBaseFileName:pathname];
    });
    return _singleton;
}

int NSLogQueryResult(void *pArg, int argc, char **argv, char **columnNames){
    for (int i=0; i<argc; i++)
        NSLog(@"%s == %s", columnNames[i], argv[i]);
    return 0;
}

-(id)initWithDataBaseFileName:(NSString*)pathname {
    sqlite3_unicode_load();

    if (_singleton!=nil) {
        self = nil;
        return _singleton;
    }
	if ((self = [super init])) {
        // Откроем базу
        int res = sqlite3_open_v2([pathname UTF8String], &database, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, NULL);
		if (res != SQLITE_OK) {
            NSLog(@"%s: Ошибка %s при открытии базы данных %@", __FUNCTION__, sqlite3_errmsg(database), pathname);
			sqlite3_close(database);
            self = nil;
            return nil;
		} else if (DEBUG_TRACE) {
            NSLog(@"%s: База данных %@ открыта без ошибок", __FUNCTION__, pathname);
        }

        char *errMsg;
        const char *pragma = "PRAGMA cache_size=10000";
        res = sqlite3_exec(database, pragma, NULL, NULL, &errMsg);
        if (res != SQLITE_OK) {
            NSLog(@"%s: error %s issuing \'%s\' directive to sqlite db", __FUNCTION__, pragma, errMsg);
            // продолжаем работать без этого
        }
        pragma = "PRAGMA temp_store=MEMORY";
        res = sqlite3_exec(database, pragma, NULL, NULL, &errMsg);
        if (res != SQLITE_OK) {
            NSLog(@"%s: error %s issuing \'%s\' directive to sqlite db", __FUNCTION__, pragma, errMsg);
            // продолжаем работать без этого
        }
        pragma = "PRAGMA synchronous=OFF";
        // Пока база только читается, но хуже с этой директивой не будет
        res = sqlite3_exec(database, pragma, NULL, NULL, &errMsg);
        if (res != SQLITE_OK) {
            NSLog(@"%s: error %s issuing \'%s\' directive to sqlite db", __FUNCTION__, pragma, errMsg);
            // продолжаем работать без этого
        }

        // Для отладки: распечатать умолчания sqlite
        if (DEBUG_TRACE) {
            pragma = "PRAGMA cache_size";
            res = sqlite3_exec(database, pragma, NSLogQueryResult, NULL, &errMsg);
            if (res != SQLITE_OK)
                NSLog(@"%s: error %s issuing \'%s\' directive to sqlite db", __FUNCTION__, pragma, errMsg);
            pragma = "PRAGMA compile_options";
            res = sqlite3_exec(database, pragma, NSLogQueryResult, NULL, &errMsg);
            if (res != SQLITE_OK)
                NSLog(@"%s: error %s issuing \'%s\' directive to sqlite db", __FUNCTION__, pragma, errMsg);
            pragma = "PRAGMA database_list";
            res = sqlite3_exec(database, pragma, NSLogQueryResult, NULL, &errMsg);
            if (res != SQLITE_OK)
                NSLog(@"%s: error %s issuing \'%s\' directive to sqlite db", __FUNCTION__, pragma, errMsg);
            pragma = "PRAGMA encoding";
            res = sqlite3_exec(database, pragma, NSLogQueryResult, NULL, &errMsg);
            if (res != SQLITE_OK)
                NSLog(@"%s: error %s issuing \'%s\' directive to sqlite db", __FUNCTION__, pragma, errMsg);
        }
        
        const char *personsCreate = "CREATE TABLE IF NOT EXISTS \"persons\" (\"name\" TEXT,\"birthday\" REAL,\"about\" TEXT,\"isfemale\" INTEGER, \"identifier\" INTEGER PRIMARY KEY AUTOINCREMENT)";
        const char *phonesCreate = "CREATE TABLE IF NOT EXISTS \"phones\" (\"identifier\" INTEGER NOT NULL,\"number\" TEXT)";
        const char *imagesCreate = "CREATE TABLE IF NOT EXISTS\"images\" (\"identifier\" INTEGER NOT NULL,\"image\" BLOB)";
        // Для картинок отдельная таблица только из-за всеобщего поверья что если уж хранить картинки в БД,
        // то только в отдельной таблице.
        
        // TODO: при реализации удаления добавить триггеры на удаление телефонов и картинок
        
        int resPersonsCreate = sqlite3_exec(database, personsCreate, NULL, NULL, &errMsg);
        int resPhonesCreate = sqlite3_exec(database, phonesCreate, NULL, NULL, &errMsg);
        int resImagesCreate = sqlite3_exec(database, imagesCreate, NULL, NULL, &errMsg);
        
        if (resPersonsCreate!=SQLITE_OK || resPhonesCreate!=SQLITE_OK || resImagesCreate!=SQLITE_OK)
        {
            NSLog(@"%s: не могу создать таблицы в базе данных", __FUNCTION__);
            sqlite3_close(database);
            self = nil;
        }
    }
	return self;
}

- (void)dealloc {
	sqlite3_close(database);
    sqlite3_unicode_free();
}

-(BOOL)addPerson:(Person*)person {
    char *errMsg;

    // TODO: экранирование имени
    NSString *sqlInsert = [NSString stringWithFormat:
        @"INSERT INTO persons (name, birthday, about, isfemale) VALUES (\"%@\", %@, %@, %i ) ",
        person.name ?: @"NULL",
        person.birthday ? [NSString stringWithFormat:@"%f", [person.birthday timeIntervalSince1970]] : @"NULL",
        person.about ?: @"NULL",
        person.isFemale ? 1 : 0 ];
    int res = sqlite3_exec(database, [sqlInsert UTF8String], NULL, NULL, &errMsg);
    
    if (res != SQLITE_OK) {
        NSLog(@"%s: ошибка %s при добавлении записи в таблицу", __FUNCTION__, errMsg);
        return NO;
    }
    
    sqlite3_int64 identifier = sqlite3_last_insert_rowid( database );
   
    if (person.phones && [person.phones count] != 0) {
        for ( NSString *number in person.phones ) {
            NSString *sqlInsertPhone = [NSString stringWithFormat:@"INSERT INTO phones (id, number) VALUES (%lli, %@) ", identifier, number];
            int res = sqlite3_exec(database, [sqlInsertPhone UTF8String], NULL, NULL, &errMsg);
            if (res != SQLITE_OK) {
                NSLog(@"%s: Ошибка %s при добавлении записи в таблицу телефонов", __FUNCTION__, errMsg);
                return NO;
            }
        }
    }
    
    if (person.image) {
        NSData *imageData = UIImageJPEGRepresentation(person.image, kCompressionQuality);
        sqlite3_stmt *stmt = NULL;
        NSString *sqlInsertImage = [NSString stringWithFormat:@"INSERT INTO images (identifier, image) VALUES (%lli, ?) ", identifier];
        res = sqlite3_prepare_v2(database, [sqlInsertImage UTF8String], -1, &stmt, NULL);
        if (res != SQLITE_OK) {
            NSLog(@"%s: ошибка %s при добавлении фото в базу данных", __FUNCTION__, errMsg);
        }
        res = sqlite3_bind_blob(stmt, 1, [imageData bytes], (int)[imageData length], SQLITE_STATIC);
        if (res != SQLITE_OK) {
            NSLog(@"%s: ошибка %s при добавлении фото в базу данных",__FUNCTION__, sqlite3_errmsg(database));
        }
        res = sqlite3_step(stmt);
        if(res != SQLITE_DONE) {
            NSLog(@"%s: ошибка %s при добавлении фото в базу данных",__FUNCTION__, sqlite3_errmsg(database));
        }
        sqlite3_finalize(stmt);
    }
 
    return YES;
}

-(BOOL)updatePerson:(Person*)person {
    char *errMsg;
    
    // TODO: экранирование имени
    NSString *sqlUpdate = [NSString stringWithFormat:
       @"UPDATE persons SET name = \"%@\", birthday = %@, about = %@, isfemale = %i WHERE identifier = %ld",
       person.name ?: @"NULL",
       person.birthday ? [NSString stringWithFormat:@"%f", [person.birthday timeIntervalSince1970]] : @"NULL",
       person.about ?: @"NULL",
       person.isFemale ? 1 : 0,
       person.identifier];
    int res = sqlite3_exec(database, [sqlUpdate UTF8String], NULL, NULL, &errMsg);
    
    if (res != SQLITE_OK) {
        NSLog(@"%s: ошибка %s при обновлении записи в таблице", __FUNCTION__, errMsg);
        return NO;
    }
    
    if (person.phones && [person.phones count] != 0) {
        NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM phones WHERE identifier = %ld", person.identifier];
        res = sqlite3_exec(database, [sqlDelete UTF8String], NULL, NULL, &errMsg);
        if (res != SQLITE_OK) {
            NSLog(@"%s: ошибка %s при обновлении записи в таблице", __FUNCTION__, errMsg);
            return NO;
        }
        for ( NSString *number in person.phones ) {
            NSString *sqlInsertPhone = [NSString stringWithFormat:@"INSERT INTO phones (id, number) VALUES (%ld, %@) ", person.identifier, number];
            int res = sqlite3_exec(database, [sqlInsertPhone UTF8String], NULL, NULL, &errMsg);
            if (res != SQLITE_OK) {
                NSLog(@"%s: Ошибка %s при добавлении записи в таблицу телефонов", __FUNCTION__, errMsg);
                return NO;
            }
        }
    }
    
    if (person.image) {
        NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM images WHERE identifier = %ld", person.identifier];
        res = sqlite3_exec(database, [sqlDelete UTF8String], NULL, NULL, &errMsg);
        if (res != SQLITE_OK) {
            NSLog(@"%s: ошибка %s при обновлении записи в таблице", __FUNCTION__, errMsg);
            return NO;
        }
        NSData *imageData = UIImageJPEGRepresentation(person.image, kCompressionQuality);
        sqlite3_stmt *stmt = NULL;
        NSString *sqlReplaceImage = [NSString stringWithFormat:@"INSERT INTO images (image, identifier) VALUES (?, %ld)", person.identifier];
        res = sqlite3_prepare_v2(database, [sqlReplaceImage UTF8String], -1, &stmt, NULL);
        if (res != SQLITE_OK) {
            NSLog(@"%s: ошибка %s при обновлении фото в базе данных", __FUNCTION__, errMsg);
        }
        res = sqlite3_bind_blob(stmt, 1, [imageData bytes], (int)[imageData length], SQLITE_STATIC);
        if (res != SQLITE_OK) {
            NSLog(@"%s: ошибка %s при обновлении фото в базе данных",__FUNCTION__, sqlite3_errmsg(database));
        }
        res = sqlite3_step(stmt);
        if(res != SQLITE_DONE) {
            NSLog(@"%s: ошибка %s при обновлении фото в базе данных",__FUNCTION__, sqlite3_errmsg(database));
        }
        sqlite3_finalize(stmt);
    }
    
    return YES;
}

-(unsigned long)personsCount {
    unsigned long count = 0;
    sqlite3_stmt *stmt;
    int res = sqlite3_prepare_v2(database, "SELECT COUNT (*) FROM persons", -1, &stmt, NULL);
    if (res != SQLITE_OK) {
        NSLog(@"%s line %i sqlite3_prepare_v2() failed", __FUNCTION__, __LINE__);
        return 0;
    }
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        count = sqlite3_column_int64(stmt, 0);
    }
    sqlite3_finalize(stmt);
    return count;
}

-(Person*)personWithOffset:(unsigned long)offset {
    long identifier = 0;
    UIImage *image = nil;
    NSString *name = nil;
    BOOL isFemale = YES;
    NSDate *birthday = nil;
    NSMutableArray *phones = [NSMutableArray new];
    NSString *about = nil;

    // Таблица persons
    // TODO: ORDER BY
    NSString *sql = [NSMutableString stringWithFormat:@"SELECT identifier, name, birthday, about, isfemale FROM persons LIMIT 1 OFFSET %lu", offset];
    
    sqlite3_stmt *stmt;
    int res = sqlite3_prepare_v2(database, [sql UTF8String], -1, &stmt, NULL);
    if (res != SQLITE_OK) {
        NSLog(@"%s line %i sqlite3_prepare_v2() failed", __FUNCTION__, __LINE__);
        return nil;
    }
    
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        identifier = sqlite3_column_int64(stmt, 0);

        const unsigned char *_name = sqlite3_column_text(stmt, 1);
        if (_name!=NULL)
            name = [NSString stringWithUTF8String:(const char*)_name];

        double _birthday = sqlite3_column_double(stmt, 2);
        if (_birthday != 0.0)
            birthday = [NSDate dateWithTimeIntervalSince1970:_birthday];
        
        const unsigned char *_about = sqlite3_column_text(stmt, 3);
        if (_about!=NULL)
            about = [NSString stringWithUTF8String:(const char*)_about];
        
        isFemale = sqlite3_column_int(stmt, 4);
    }
    sqlite3_finalize(stmt);

    // Таблица images
    
    sql = [NSMutableString stringWithFormat:@"SELECT image FROM images WHERE identifier = %lu", identifier];
    
    res = sqlite3_prepare_v2(database, [sql UTF8String], -1, &stmt, NULL);
    if (res != SQLITE_OK) {
        NSLog(@"%s line %i sqlite3_prepare_v2() failed", __FUNCTION__, __LINE__);
        return nil;
    }
    
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        const void *_bytes = sqlite3_column_blob(stmt, 0);
        if (_bytes!=NULL) {
            int length = sqlite3_column_bytes(stmt, 0);
            image = [UIImage imageWithData:[NSData dataWithBytes:_bytes length:length]];
        }
    }
    sqlite3_finalize(stmt);
    
    // Таблица phones
    
    sql = [NSMutableString stringWithFormat:@"SELECT number FROM phones WHERE identifier = %lu", identifier];
    
    res = sqlite3_prepare_v2(database, [sql UTF8String], -1, &stmt, NULL);
    if (res != SQLITE_OK) {
        NSLog(@"%s line %i sqlite3_prepare_v2() failed", __FUNCTION__, __LINE__);
        return nil;
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        const unsigned char *_number = sqlite3_column_text(stmt, 0);
        if (_number!=NULL)
            [phones addObject: [NSString stringWithUTF8String:(const char*)_number]];
    }
    sqlite3_finalize(stmt);

    return [[Person alloc] initWithId:identifier image:image name:name birthday:birthday phones:[phones copy] about:about isFemale:isFemale];
}

@end

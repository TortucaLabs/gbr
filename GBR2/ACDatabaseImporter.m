//
//  ACDatabaseImporter.m
//  GBR2
//
//  Created by Andrew J Cavanagh on 2/23/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACDatabaseImporter.h"
#import "ACCDMgr.h"
#import "parseCSV.h"

@interface ACDatabaseImporter()
@property (nonatomic, strong) NSArray *allQuestions;
@property (nonatomic, strong) NSMutableArray *allDataSets;
@property (nonatomic) int totalQuestionCount;
@end

@implementation ACDatabaseImporter


- (void)loadData
{
    self.allDataSets = [[NSMutableArray alloc] init];
    
    NSString *cat0 = [[NSBundle mainBundle] pathForResource:@"0" ofType:@"csv"];
    NSString *cat1 = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"csv"];
    NSString *cat2 = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"csv"];
    NSString *cat3 = [[NSBundle mainBundle] pathForResource:@"3" ofType:@"csv"];
    NSString *cat4 = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"csv"];
    NSString *cat5 = [[NSBundle mainBundle] pathForResource:@"5" ofType:@"csv"];
    NSString *cat6 = [[NSBundle mainBundle] pathForResource:@"6" ofType:@"csv"];
    NSString *cat7 = [[NSBundle mainBundle] pathForResource:@"7" ofType:@"csv"];
    NSString *cat8 = [[NSBundle mainBundle] pathForResource:@"8" ofType:@"csv"];
    NSString *cat9 = [[NSBundle mainBundle] pathForResource:@"9" ofType:@"csv"];
    
    NSArray *categories = @[cat0, cat1, cat2, cat3, cat4, cat5, cat6, cat7, cat8, cat9];
    
    self.totalQuestionCount = 0;
    int categoryID = 0; // keeps track of category id
    
    NSMutableArray *totalQuestionSet = [[NSMutableArray alloc] init];
    for (NSString *file in categories)
    {
        NSLog(@"Perfomring Loop: %i", (categoryID+1));
        
        NSData *fileData = [NSData dataWithContentsOfFile:file];
        CSVParser *p = [CSVParser new];
        [p setEncoding:NSMacOSRomanStringEncoding];
        NSMutableArray *parsedData = [p parseData:fileData];
        
        [self shuffleArray:parsedData];
    
        int index = 0;
        NSMutableArray *questionObjects = [[NSMutableArray alloc] init];
        for (NSArray *qA in parsedData)
        {
            int uidNum = self.totalQuestionCount;
            Questions *nQ = [NSEntityDescription insertNewObjectForEntityForName:@"Questions" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
            nQ.uid = [NSNumber numberWithInt:uidNum];
            nQ.id = [NSNumber numberWithInt:index];
            nQ.category = [NSNumber numberWithInt:categoryID];
            nQ.question = qA[1];
            nQ.answer0 = qA[2];
            nQ.answer1 = qA[3];
            nQ.answer2 = qA[4];
            nQ.answer3 = qA[5];
            nQ.book = qA[6];
            nQ.bcv = qA[7];

            [questionObjects addObject:nQ];
            index++;
            self.totalQuestionCount++;
        }
        [self prepareForRoundCalculationWithQuestionCount:questionObjects.count andCategoryID:categoryID];
        [totalQuestionSet addObject:questionObjects];
        categoryID++;
    }
    
    self.allQuestions = (NSArray *)totalQuestionSet;
    [self writeDataSets];
}

- (void)prepareForRoundCalculationWithQuestionCount:(int)count andCategoryID:(int)catID
{
    NSDictionary *metaData;
    switch (catID) {
        case 0:
            metaData = @{@"catID" : [NSNumber numberWithInt:catID], @"name" : @"General", @"identifier" : @"cat0"};
            break;
        
        case 1:
            metaData = @{@"catID" : [NSNumber numberWithInt:catID], @"name" : @"Law", @"identifier" : @"cat1"};
            break;
            
        case 2:
            metaData = @{@"catID" : [NSNumber numberWithInt:catID], @"name" : @"History", @"identifier" : @"cat2"};
            break;
            
        case 3:
            metaData = @{@"catID" : [NSNumber numberWithInt:catID], @"name" : @"Poetry and Wisdom", @"identifier" : @"cat3"};
            break;
            
        case 4:
            metaData = @{@"catID" : [NSNumber numberWithInt:catID], @"name" : @"Prophets", @"identifier" : @"cat4"};
            break;
            
        case 5:
            metaData = @{@"catID" : [NSNumber numberWithInt:catID], @"name" : @"Gospels", @"identifier" : @"cat5"};
            break;
            
        case 6:
            metaData = @{@"catID" : [NSNumber numberWithInt:catID], @"name" : @"Early Church", @"identifier" : @"cat6"};
            break;
            
        case 7:
            metaData = @{@"catID" : [NSNumber numberWithInt:catID], @"name" : @"Letters", @"identifier" : @"cat7"};
            break;
            
        case 8:
            metaData = @{@"catID" : [NSNumber numberWithInt:catID], @"name" : @"Prophecy", @"identifier" : @"cat8"};
            break;
            
        case 9:
            metaData = @{@"catID" : [NSNumber numberWithInt:catID], @"name" : @"Kids", @"identifier" : @"cat9"};
            break;
            
        default:
        {
            NSLog(@"ERROR!!!!!");
            abort();
        }
            break;
    }
    
    [self calculateRoundsDataForQuestionCount:count withMetaData:metaData];
}

// new revised algorithm (in use)
- (void)calculateRoundsDataForQuestionCount:(int)count withMetaData:(NSDictionary *)metaData
{
    float suggestedQuestionsPerPool = (float)count / 60.0f; // @ 60 rounds
    NSLog(@"Suggesting %f Questions Per Round", suggestedQuestionsPerPool);
    
    int remainder = count%60;
    NSLog(@"remainder: %i", remainder);
    
    int roundIndex = 0;
    int questionsPerRoundPool = suggestedQuestionsPerPool;
    
    if (questionsPerRoundPool < 10) //minimum allowable question pool
    {
        questionsPerRoundPool = 10;
    }
    
    NSLog(@"Actually Using %f Questions Per Round", (float)questionsPerRoundPool);
    
    int poolIndex = 0;
    int questionIndex = 0;
    int totalQuestionsForCategory = count;
    int currentStartQuestion = 0;
    int currentEndQuestion = questionsPerRoundPool - 1;
    NSMutableArray *roundsIndexArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < totalQuestionsForCategory; i++)
    {
        if ((poolIndex == questionsPerRoundPool) || (questionIndex == (totalQuestionsForCategory - 1)))
        {
            NSLog(@"POOL INDEX IS: %i", poolIndex);
            if (poolIndex >= 10) // rounds need a minimum of 10 questions
            {
                currentEndQuestion = questionIndex - 1;
                currentStartQuestion = questionIndex - questionsPerRoundPool;
                
                NSDictionary *dictionary = @{@"roundStart" : [NSNumber numberWithInt:currentStartQuestion],
                                             @"roundEnd"   : [NSNumber numberWithInt:currentEndQuestion]};
                
                if (roundIndex < 60)
                {
                    [roundsIndexArray addObject:dictionary]; // set max rounds to 60!
                    roundIndex++;
                }
            }
            else
            {
                NSLog(@"Round is less than 10 questions, not adding");
            }
            poolIndex = 0;
        }
        poolIndex++;
        questionIndex++;
    }
        
    //NSLog(@"%@", [roundsIndexArray description]);
    NSLog(@"%i Round generated from %i questions at %i questions per round", roundsIndexArray.count, totalQuestionsForCategory, questionsPerRoundPool);
    NSLog(@"\n");
    NSLog(@"\n");
    
    NSMutableDictionary *masterCategoryOneDictionary = [[NSMutableDictionary alloc] init];
    
    int catID = [[metaData valueForKey:@"catID"] intValue];
    NSString *name = [metaData valueForKey:@"name"];
    NSString *identifier = [metaData valueForKey:@"identifier"];
    
    [masterCategoryOneDictionary setValue:[NSNumber numberWithInt:catID] forKey:@"catID"];
    [masterCategoryOneDictionary setValue:name forKey:@"name"];
    [masterCategoryOneDictionary setValue:identifier forKey:@"identifier"];
    [masterCategoryOneDictionary setValue:roundsIndexArray forKey:@"rounds"];
    
    [self.allDataSets addObject:masterCategoryOneDictionary];
}

// old algorithm (not in use)   
- (void)calculateRoundsDataForQuestionCount:(int)count questionsPerRound:(int)qpp withMetaData:(NSDictionary *)metaData
{
    float suggestedQuestionsPerPool = (float)count / 60.0f; // @ 60 rounds
    NSLog(@"Suggesting %f Questions Per Round", suggestedQuestionsPerPool);
    
    int roundIndex = 0;
    int questionsPerRoundPool = suggestedQuestionsPerPool;
    
    if (questionsPerRoundPool < 10)
    {
        questionsPerRoundPool = 10;
    }
    
    NSLog(@"Actually Using %f Questions Per Round", (float)questionsPerRoundPool);
    
    int poolIndex = 0;
    int questionIndex = 0;
    int totalQuestionsForCategory = count;
    int currentStartQuestion = 0;
    int currentEndQuestion = questionsPerRoundPool - 1;
    NSMutableArray *roundsIndexArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < totalQuestionsForCategory; i++)
    {
        if ((poolIndex == questionsPerRoundPool) || (questionIndex == (totalQuestionsForCategory - 1)))
        {
            currentEndQuestion = questionIndex - 1;
            currentStartQuestion = questionIndex - questionsPerRoundPool;
            
            NSDictionary *dictionary = nil;
            if (questionIndex == (totalQuestionsForCategory - 1))
            {
                dictionary = @{@"roundStart" : [NSNumber numberWithInt:currentStartQuestion],
                               @"roundEnd"   : [NSNumber numberWithInt:currentEndQuestion+1]};
            }
            else
            {
                dictionary = @{@"roundStart" : [NSNumber numberWithInt:currentStartQuestion],
                               @"roundEnd"   : [NSNumber numberWithInt:currentEndQuestion]};
            }
            
            if (roundIndex < 60)
            {
                [roundsIndexArray addObject:dictionary]; // set max rounds to 60!
                roundIndex++;
                
                // last round sanity check
                int end = [[dictionary valueForKey:@"roundEnd"] intValue];
                int start = [[dictionary valueForKey:@"roundStart"] intValue];
                int roundQuestions = end - start;
                
                if (roundQuestions < questionsPerRoundPool)
                {
                    NSLog(@"ILLEGAL ROUNDd... REMOVING (%i question in round, %i required)", roundQuestions, questionsPerRoundPool);
                }
                
            }
            poolIndex = 0;
        }
        
        //NSLog(@"Pool Index: %i", poolIndex);
        
        poolIndex++;
        questionIndex++;
    }
    
    //NSLog(@"%@", [roundsIndexArray description]);
    NSLog(@"%i Round generated from %i questions at %i questions per round", roundsIndexArray.count, totalQuestionsForCategory, questionsPerRoundPool);
    
    NSMutableDictionary *masterCategoryOneDictionary = [[NSMutableDictionary alloc] init];
    
    int catID = [[metaData valueForKey:@"catID"] intValue];
    NSString *name = [metaData valueForKey:@"name"];
    NSString *identifier = [metaData valueForKey:@"identifier"];
    
    [masterCategoryOneDictionary setValue:[NSNumber numberWithInt:catID] forKey:@"catID"];
    [masterCategoryOneDictionary setValue:name forKey:@"name"];
    [masterCategoryOneDictionary setValue:identifier forKey:@"identifier"];
    [masterCategoryOneDictionary setValue:roundsIndexArray forKey:@"rounds"];
    
    [self.allDataSets addObject:masterCategoryOneDictionary];
}

- (void)shuffleArray:(NSMutableArray *)array
{
    NSUInteger count = array.count;
    for (NSUInteger i = 0; i < count; ++i)
    {
        NSInteger nElements = count - i;
        NSInteger n = (arc4random_uniform(nElements)) + 1;
        
        if (i < array.count && n < array.count) // check out of bounds error
        {
            [array exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
    }
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)writeDataSets
{
    NSString *file = [NSString stringWithFormat:@"%@/categories.plist", [[self applicationDocumentsDirectory] path]];
    [self.allDataSets writeToFile:file atomically:NO];
    NSLog(@"WRITTEN DATASET TO: %@", file);
    
    NSLog(@"TOTAL QUESTION COUNT: %i", self.totalQuestionCount);
    
    MetaData *metaData = [[ACCDMgr sharedCDManager] metaDataObject];
    if (!metaData)
    {
        metaData = [NSEntityDescription insertNewObjectForEntityForName:@"MetaData" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
    }
    
    metaData.totalQuestionCount = [NSNumber numberWithInt:self.totalQuestionCount];
    NSError *error;
    [[ACCDMgr sharedCDManager].managedObjectContext save:&error];
    if (error) NSLog(@"Save Error: %@", [error description]);
    else NSLog(@"DATA SET GENERATION COMPLETED!");
}




























































































































































































































































































- (void)beginDataGeneration
{
    self.allDataSets = [[NSMutableArray alloc] init];
    self.totalQuestionCount = 0;
    
    [self buildCategoryOne];
    [self buildCategoryTwo];
    [self buildCategoryThree];
    [self buildCategoryFour];
    [self buildCategoryFive];
    [self buildCategorySix];
    [self buildCategorySeven];
    [self buildCategoryEight];
    
    [self writeDataSets];
}

#pragma mark - CATEGORY DATA ASSIGNMENT

- (void)buildCategoryOne
{
    NSLog(@"Reading Category 1");
    NSMutableString *totalStringData = [[NSMutableString alloc] init];
    NSError *error = nil;
    for (int i = 1; i < 6; i++)
    {
        //NSLog(@"Reading File: %i", i);
        NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%i", i] ofType:@"txt"];
        NSString *data = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            NSLog(@"Read Error On File %i: %@", i, [error description]);
            abort();
        }
        [totalStringData appendString:data];
    }
    
    NSDictionary *metaData = @{@"catID" : [NSNumber numberWithInt:0], @"name" : @"Law", @"identifier" : @"GBR2.LawCategory"};
    [self scanDataSet:totalStringData withMetaData:metaData];
}

- (void)buildCategoryTwo
{
    NSLog(@"Reading Category 2");
    NSMutableString *totalStringData = [[NSMutableString alloc] init];
    NSError *error = nil;
    for (int i = 6; i < 18; i++)
    {
        //NSLog(@"Reading File: %i", i);
        NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%i", i] ofType:@"txt"];
        NSString *data = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            NSLog(@"Read Error On File %i: %@", i, [error description]);
            abort();
        }
        [totalStringData appendString:data];
    }
    
    NSDictionary *metaData = @{@"catID" : [NSNumber numberWithInt:1], @"name" : @"History", @"identifier" : @"GBR2.HistoryCategory"};
    [self scanDataSet:totalStringData withMetaData:metaData];
}

- (void)buildCategoryThree
{
    
}

- (void)buildCategoryFour
{
    NSLog(@"Reading Category 4");
    NSMutableString *totalStringData = [[NSMutableString alloc] init];
    NSError *error = nil;
    
    NSArray *books = @[@23, @24, @26, @27, @28, @29, @30, @31, @32, @33, @34, @35, @36, @37, @38, @39];
    
    int i;
    for (NSNumber *bookNum in books)
    {
        i = [bookNum intValue];
        NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%i", i] ofType:@"txt"];
        NSString *data = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            NSLog(@"Read Error On File %i: %@", i, [error description]);
            abort();
        }
        [totalStringData appendString:data];
    }
    
    NSDictionary *metaData = @{@"catID" : [NSNumber numberWithInt:3], @"name" : @"Prophets", @"identifier" : @"GBR2.ProphetsCategory"};
    [self scanDataSet:totalStringData withMetaData:metaData];
}

- (void)buildCategoryFive
{
    
}

- (void)buildCategorySix
{
    
}

- (void)buildCategorySeven
{
    
}

- (void)buildCategoryEight
{
    NSLog(@"Reading Category 8");
    NSMutableString *totalStringData = [[NSMutableString alloc] init];
    NSError *error = nil;
    
    NSArray *books = @[@58, @59, @60, @61, @62, @63, @64, @65, @68];
    
    int i;
    for (NSNumber *bookNum in books)
    {
        i = [bookNum intValue];
        NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%i", i] ofType:@"txt"];
        NSString *data = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            NSLog(@"Read Error On File %i: %@", i, [error description]);
            abort();
        }
        [totalStringData appendString:data];
    }
    
    NSDictionary *metaData = @{@"catID" : [NSNumber numberWithInt:7], @"name" : @"General Letters", @"identifier" : @"GBR2.GeneralLettersCategory"};
    [self scanDataSet:totalStringData withMetaData:metaData];
}

#pragma mark - DATABASE GENERATION LOGIC

- (void)scanDataSet:(NSString *)totalStringData withMetaData:(NSDictionary *)metaData
{
    NSLog(@"Scanning...");
    int index = 0;
    NSScanner *scanner = [NSScanner scannerWithString:totalStringData];
    NSCharacterSet *newLine = [NSCharacterSet newlineCharacterSet];
    NSMutableArray *questions = [[NSMutableArray alloc] init];
    NSMutableArray *seenQuestions = [[NSMutableArray alloc] init];
    NSMutableArray *indices = [[NSMutableArray alloc] init];
    
    while (![scanner isAtEnd])
    {
        NSString *currentQuestion = nil;
        NSString *currentAnswer0 = nil;
        NSString *currentAnswer1 = nil;
        NSString *currentAnswer2 = nil;
        NSString *currentAnswer3 = nil;
        NSString *currentBookChapterVerse = nil;
        
        [scanner scanUpToCharactersFromSet:newLine intoString:&currentQuestion];
        [scanner scanCharactersFromSet:newLine intoString:nil];
        [scanner scanUpToCharactersFromSet:newLine intoString:&currentAnswer0];
        [scanner scanCharactersFromSet:newLine intoString:nil];
        [scanner scanUpToCharactersFromSet:newLine intoString:&currentAnswer1];
        [scanner scanCharactersFromSet:newLine intoString:nil];
        [scanner scanUpToCharactersFromSet:newLine intoString:&currentAnswer2];
        [scanner scanCharactersFromSet:newLine intoString:nil];
        [scanner scanUpToCharactersFromSet:newLine intoString:&currentAnswer3];
        [scanner scanCharactersFromSet:newLine intoString:nil];
        [scanner scanUpToCharactersFromSet:newLine intoString:&currentBookChapterVerse];
        [scanner scanCharactersFromSet:newLine intoString:nil];
        [scanner scanUpToCharactersFromSet:newLine intoString:nil];
        [scanner scanCharactersFromSet:newLine intoString:nil];
        
        if (![seenQuestions containsObject:currentQuestion])
        {
            [seenQuestions addObject:currentQuestion];
            NSArray *questionComponents = @[currentQuestion, currentAnswer0, currentAnswer1, currentAnswer2, currentAnswer3, currentBookChapterVerse, [NSNumber numberWithInt:0]];
            [questions addObject:questionComponents];
            
            [indices addObject:[NSNumber numberWithInt:index]];
            index++;
        }
    }
    
    int x = 0;
    while (x < 100) {
        [self shuffleArray:indices];
        x++;
    }

    int tempIndex = 0;
    NSMutableArray *questionObjects = [[NSMutableArray alloc] init];
    for (NSArray *qA in questions)
    {
        Questions *nQ = [NSEntityDescription insertNewObjectForEntityForName:@"Questions" inManagedObjectContext:[ACCDMgr sharedCDManager].managedObjectContext];
        nQ.id = [indices objectAtIndex:tempIndex];
        nQ.question = qA[0];
        nQ.answer0 = qA[1];
        nQ.answer1 = qA[2];
        nQ.answer2 = qA[3];
        nQ.answer3 = qA[4];
        nQ.bcv = qA[5];
        nQ.category = qA[6];
        
        int uidNum = self.totalQuestionCount;
        nQ.uid = [NSNumber numberWithInt:uidNum];
        
        [questionObjects addObject:nQ];
        tempIndex++;
        self.totalQuestionCount++;
    }
    
    [self calculateRoundsDataForQuestionCount:questionObjects.count questionsPerRound:25 withMetaData:metaData];
    
    NSError *error;
    [[ACCDMgr sharedCDManager].managedObjectContext save:&error];
    if (error) NSLog(@"Save Error: %@", [error description]);
    else [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"questionsLoaded"];
    
    NSLog(@"%i Objets Added to Database", index);
}


//- (void)shuffleArray:(NSMutableArray *)array
//{
//    NSUInteger count = array.count;
//    for (NSUInteger i = 0; i < count; ++i)
//    {
//        NSInteger nElements = count - i;
//        NSInteger n = (arc4random_uniform(nElements)) + 1;
//        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
//    }
//}



@end

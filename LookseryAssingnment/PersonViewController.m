//
//  PersonViewController.m
//  LookseryAssingnment
//
//  Created by Valeriy Van on 09.03.15.
//  Copyright (c) 2015 looksery.com. All rights reserved.
//

#import "PersonViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PersonsDatabase.h"

static NSString *kNameCell = @"name";
const NSInteger kNameCell_nameTag = 1;

static NSString *kImageCell = @"image";
const NSInteger kImageCell_imageTag = 1;
const NSInteger kImageCell_buttonTag = 2;

static NSString *kSexCell = @"sex";
const NSInteger kSexCell_switchTag = 1;
const NSInteger kSexCell_labelTag = 2;

static NSString *kBirthdayCell = @"birthday";
const NSInteger kBirthdayCell_labelTag = 1;

static NSString *kBirthdayPickerCell = @"birthday picker";
const NSInteger kBirthdayPickerCell_pickerTag = 1;

static NSString *kPhoneCell = @"phone";
const NSInteger kPhoneCell_labelTag = 1;

static NSString *kAboutCell = @"about";
const NSInteger kAboutCell_textViewTag = 1;

static NSString *kEmptyCell = @"empty";

@interface PersonViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UITableViewCell *cellWithImage;

    // Контрол который сейчас редактируется
    // Если будет нажата кнопка done, редактирование этого контрола надо завершить насильно,
    // чтоб дать отработать делегатам которые сохранят данные.
    UIResponder *controlBeingEdited;

    BOOL isDateOpen; // birthday cell
    UIDatePicker *datePicker;
}
@end

@implementation PersonViewController
@synthesize person = _person;

#pragma mark - Managing the detail item

- (void)setPerson:(Person *)newPerson {
    if (_person != newPerson) {
        _person = newPerson;
            
        // Update the view.
        [self.tableView reloadData];
    }
}

- (Person*)person {
    if (_person == nil) {
        _person = [[Person alloc] init];
    }
    return _person;
}

- (void)setChanged:(BOOL)f {
    _changed = f;
    if (_changed) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)setEditMode:(BOOL)newMode {
    _editMode = newMode;
    if (_editMode) {
        [self addCancelAndDoneButtons];
    } else {
        [self removeCancelAndDoneButtons];
        [self addEditButtonAndRemoveCancelButton];
    }
    // TODO: добавить переключение редактируемости всех контролов в таблице
    [self.tableView reloadData]; // поменяет режим редактирвоания во всех контролах
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (!self.editMode) {
        [self addCancelAndDoneButtons];
    } else {
        [self addEditButtonAndRemoveCancelButton];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCancelAndDoneButtons {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)removeCancelAndDoneButtons {
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)addEditButtonAndRemoveCancelButton {
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
}

- (IBAction)cancel:(UIBarButtonItem*)sender {
    [self setChanged:NO];
    // TODO: уж сильно этот контроллер завязан на то как именно он используется.
    if ([self.person isNewRecord]) { // TODO: криво; нужно еще  одно состояние
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.personViewControllerDelegate.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)done:(UIBarButtonItem*)sender {
    [controlBeingEdited resignFirstResponder];
    // TODO: уж сильно этот контроллер завязан на то как именно он используется.
    // Пусть делегаты думают как надо dismiss или pop
    if ([self.person isNewRecord]) { // TODO: криво; нужно еще  одно состояние
        [self.personViewControllerDelegate personViewController:self addPerson:self.person];
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.personViewControllerDelegate personViewController:self updatePerson:self.person];
        [self.personViewControllerDelegate.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)edit:(UIBarButtonItem*)sender {
    self.editMode = YES; // NO здесь быть не может
}

- (BOOL)controlsAllowEditing {
    return self.person.isNewRecord || self.editMode;
}

#pragma mark - UITableViewDelegate и UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5 + (self.person.phones.count > 0 ? self.person.phones.count : 1) + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 1: // image
            return 100;
        case 4: // picker for birthday
            return isDateOpen ? 219 : 0;
        default:
            return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSLog(@"indexPath.row = %ld", indexPath.row);

    // Вот здесь switch из swift развернулся бы во всей красе!..
    if (indexPath.row == 0) {
        NSLog(@"Сделали ячейку с именем");
        cell = [self.tableView dequeueReusableCellWithIdentifier:kNameCell forIndexPath:indexPath];
        UITextField *nameTextField = (UITextField*)[cell.contentView viewWithTag:kNameCell_nameTag];
        nameTextField.text = self.person.name;
        nameTextField.userInteractionEnabled = [self controlsAllowEditing];
    } else if (indexPath.row == 1) {
        NSLog(@"Сделали ячейку с картинкой");
        cell = [self.tableView dequeueReusableCellWithIdentifier:kImageCell forIndexPath:indexPath];
        UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:kImageCell_imageTag];
        // TODO: почему-то упрямо не хочет устанавливать это в IB
        imageView.layer.borderColor = [[UIColor blackColor] CGColor];
        imageView.layer.borderWidth = 1.0;
        imageView.layer.cornerRadius = 5.0;
        imageView.image = self.person.image;
        UIButton *button = (UIButton*)[cell.contentView viewWithTag:kImageCell_buttonTag];
        button.enabled = [self controlsAllowEditing];
    } else if (indexPath.row == 2) {
        NSLog(@"Сделали ячейку с полом");
        cell = [self.tableView dequeueReusableCellWithIdentifier:kSexCell forIndexPath:indexPath];
        UISwitch *aswitch = (UISwitch*)[cell.contentView viewWithTag:kSexCell_switchTag];
        aswitch.on = self.person.isFemale;
        UILabel *l = (UILabel*)[cell.contentView viewWithTag:kSexCell_labelTag];
        l.text = self.person.isFemale ? @"is female" : @"is male";
        aswitch.enabled = [self controlsAllowEditing];
    }  else if (indexPath.row == 3) {
        NSLog(@"Сделали ячейку с датой рождения");
        cell = [self.tableView dequeueReusableCellWithIdentifier:kBirthdayCell forIndexPath:indexPath];
        UILabel *l = (UILabel*)[cell.contentView viewWithTag:kBirthdayCell_labelTag];
        l.text = [self birthdayStringFromDate:self.person.birthday];
    }  else if (indexPath.row == 4) {
        NSLog(@"Сделали ячейку с пикером даты");
        cell = [self.tableView dequeueReusableCellWithIdentifier:kBirthdayPickerCell forIndexPath:indexPath];
        datePicker = (UIDatePicker*)[cell.contentView viewWithTag:kBirthdayPickerCell_pickerTag];
        if (self.person.birthday != nil) {
            datePicker.date = self.person.birthday;
        }
        datePicker.enabled = isDateOpen;
        datePicker.alpha = isDateOpen ? 1.0 : 0.0;
    } else if ((indexPath.row > 4) && (indexPath.row <= 4 + (self.person.phones.count > 0 ? self.person.phones.count : 1))) {
        NSLog(@"Сделали ячейку с телефоном");
        // Когда телефонов нет все равно под телефон должна быть одна ячейка
        cell = [self.tableView dequeueReusableCellWithIdentifier:kPhoneCell forIndexPath:indexPath];
        UILabel *l = (UILabel*)[cell.contentView viewWithTag:kPhoneCell_labelTag];
        if (self.person.phones.count != 0 ) {
            NSInteger phoneIndex = indexPath.row - 4 - 1;
            l.text = self.person.phones[phoneIndex];
        } else {
            l.text = @"Phone not set";
        }
    } else if (indexPath.row == 4 + (self.person.phones.count > 0 ? self.person.phones.count : 1) + 1) {
        NSLog(@"Сделали ячейку about");
        cell = [self.tableView dequeueReusableCellWithIdentifier:kAboutCell forIndexPath:indexPath];
        cell.textLabel.text = @"Тут будет about";
    } else {
        NSLog(@"Сделали пустую ячейку");
        cell = [self.tableView dequeueReusableCellWithIdentifier:kEmptyCell forIndexPath:indexPath];
        cell.backgroundColor = [UIColor redColor];
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.editMode ? indexPath : nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3){
        if (isDateOpen) {
            [self hideDatePickerCell];
        } else {
            [self showDatePickerCell];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showDatePickerCell {
    isDateOpen = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    datePicker.hidden = NO;
    datePicker.alpha = 0.0f;
    [UIView animateWithDuration:0.25 animations:^{
        datePicker.alpha = 1.0f;
    } completion:^(BOOL finished) {
        //datePicker.superview.superview.clipsToBounds = NO;
        datePicker.enabled = YES;
    }];
}

- (void)hideDatePickerCell {
    isDateOpen = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:0.25 animations:^{
        datePicker.alpha = 0.0f;
    } completion:^(BOOL finished) {
        datePicker.hidden = YES;
        datePicker.enabled = NO;
        //datePicker.superview.superview.clipsToBounds = YES;
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self setChanged:YES];
    controlBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    self.person.name = textField.text;
    self.changed = YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (IBAction)imageButtonPressed:(UIButton*)sender {
    cellWithImage = (UITableViewCell*)[[sender superview] superview];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^ {
        UIImage *image = info[UIImagePickerControllerEditedImage];
        self.person.image = image;
        UIImageView *imageView = (UIImageView*)[cellWithImage viewWithTag:kImageCell_imageTag];
        imageView.image = image;
        self.changed = YES;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (IBAction)sexSwitchChanged:(UISwitch*)sender {
    self.person.isFemale = sender.isOn;
    UILabel *l = (UILabel*)[sender.superview viewWithTag:kSexCell_labelTag];
    l.text = self.person.isFemale ? @"is female" : @"is male";
    [self setChanged:YES];
}

#pragma mark -

- (IBAction)datePickerChanged:(UIDatePicker*)sender {
    self.person.birthday = sender.date;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    UILabel *l = (UILabel*)[cell.contentView viewWithTag:kBirthdayCell_labelTag];
    l.text = [self birthdayStringFromDate:sender.date];
    [self setChanged:YES];
}

#pragma mark -

// Helper
- (NSString*)birthdayStringFromDate:(NSDate*)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MM yyyy"];
    return [NSString stringWithFormat:@"Birthday %@", [formatter stringFromDate:self.person.birthday] ?: @"not set"];
}
@end

//
//  TNKViewController.m
//  TNKImagePickerController
//
//  Created by David Beck on 02/17/2015.
//  Copyright (c) 2014 David Beck. All rights reserved.
//

#import "TNKViewController.h"

#import <TNKImagePickerController/TNKImagePickerController.h>


@interface TNKViewController () <TNKImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *singlePhotoModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *photoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *videoSwitch;

@end

@implementation TNKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self pickPhotos:nil];
    });
}


#pragma mark - Actions

- (IBAction)pickPhotos:(id)sender
{
    TNKImagePickerController *picker = [[TNKImagePickerController alloc] init];
	
	NSMutableArray *mediaTypes = [NSMutableArray new];
	if (self.photoSwitch.on) {
		[mediaTypes addObject:(id)kUTTypeImage];
	}
	if (self.videoSwitch.on) {
		[mediaTypes addObject:(id)kUTTypeVideo];
	}
    picker.mediaTypes = mediaTypes;
	
	picker.pickerDelegate = self;
	
	if (self.singlePhotoModeSwitch.on) {
		picker.hideSelectAll = YES;
	}
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:picker];
    navigationController.toolbarHidden = NO;
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    
    navigationController.popoverPresentationController.sourceView = self.pickPhotosButton;
    navigationController.popoverPresentationController.sourceRect = self.pickPhotosButton.bounds;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)pickSinglePhoto:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark - TNKImagePickerControllerDelegate

- (void)imagePickerController:(TNKImagePickerController *)picker
       didFinishPickingAssets:(NSArray *)assets {
    [[PHImageManager defaultManager] tnk_requestImagesForAssets:assets targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(NSDictionary *results, NSDictionary *infos) {
        NSArray *images = results.allValues;
        NSLog(@"images: %@", images);
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(TNKImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)imagePickerControllerTitleForDoneButton:(TNKImagePickerController *)picker {
	if (picker.selectedAssets.count > 0) {
		return [NSString localizedStringWithFormat:NSLocalizedString(@"Next (%d)", @"Title for photo picker done button (short)."), picker.selectedAssets.count];
	} else {
		return NSLocalizedString(@"Next", nil);
	}
}

- (NSArray<PHAsset *> *)imagePickerController:(TNKImagePickerController *)picker shouldSelectAssets:(NSArray<PHAsset *> *)assets {
	if (self.singlePhotoModeSwitch.on && assets.count > 0) {
		picker.selectedAssets = @[ assets.lastObject ];
		
		return @[];
	}
	
	return assets;
}

@end

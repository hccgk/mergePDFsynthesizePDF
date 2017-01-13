//
//  ViewController.m
//  mergePDFsynthesizePDF
//
//  Created by 川何 on 2017/1/13.
//  Copyright © 2017年 hechuan. All rights reserved.
//

#import "ViewController.h"
#import "UIView+JKFrame.h"
@interface ViewController ()
@property(nonatomic,strong)UIView *coverView;
@property(nonatomic,strong)UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeUI];
}

-(void)makeUI{
    UIButton *mergeBtn = [UIButton new];

    mergeBtn.frame = CGRectMake(0, 0, 200, 100);
    mergeBtn.backgroundColor = [UIColor grayColor];
    mergeBtn.center = self.view.center;
    [mergeBtn setTitle:@"合并PDF" forState:UIControlStateNormal];
    [mergeBtn addTarget:self action:@selector(merge) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mergeBtn];
    
   
    
    UIButton *firstPdfBtn = [UIButton new];
    firstPdfBtn.frame = CGRectMake(0, 0, 200, 100);
    
    firstPdfBtn.backgroundColor = [UIColor grayColor];
    firstPdfBtn.center = self.view.center;
    [firstPdfBtn setTitle:@"查看baiduPDF" forState:UIControlStateNormal];
    firstPdfBtn.tag = 1;
    [firstPdfBtn addTarget:self action:@selector(show:) forControlEvents:UIControlEventTouchUpInside];
    [firstPdfBtn setJk_centerY: mergeBtn.jk_centerY - 120];
    [self.view addSubview:firstPdfBtn];
    
    UIButton *secendPdfBtn = [UIButton new];
    secendPdfBtn.frame = CGRectMake(0, 0, 200, 100);
    secendPdfBtn.backgroundColor = [UIColor grayColor];
    secendPdfBtn.center = self.view.center;
    secendPdfBtn.tag = 2;
    [secendPdfBtn setTitle:@"查看YouTubePDF" forState:UIControlStateNormal];
    [secendPdfBtn addTarget:self action:@selector(show:) forControlEvents:UIControlEventTouchUpInside];
    [secendPdfBtn setJk_centerY: mergeBtn.jk_centerY + 120];
    [self.view addSubview:secendPdfBtn];
    
    
    self.coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.coverView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.coverView];
    self.coverView.hidden = YES;
    
    self.webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.coverView addSubview:self.webView];
    
    UIButton *bottomBtn = [UIButton new];
    [self.webView addSubview:bottomBtn];
    [bottomBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [bottomBtn setBackgroundColor:[UIColor colorWithRed:0.2 green:0.5 blue:0.8 alpha:1]];
    [bottomBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    bottomBtn.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, [UIScreen mainScreen].bounds.size.width, 44);
    
}

-(void)closeAction{
    self.coverView.hidden = YES;
}

-(void)show:(UIButton*)btn{
    if(btn.tag == 1){
        //查看第一个pdf
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"baidu" withExtension:@"pdf"];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:fileUrl];
        
        [self.webView loadRequest:request];
        self.coverView.hidden = NO;
    }else{
     
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"YouTube" withExtension:@"pdf"];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:fileUrl];
        
        [self.webView loadRequest:request];
        self.coverView.hidden = NO;


    }
}
-(void)merge{
    NSString *baidupdf = [[NSBundle mainBundle] pathForResource:@"baidu" ofType:@"pdf"];
    NSString *youtubepdf = [[NSBundle mainBundle] pathForResource:@"YouTube" ofType:@"pdf"];
    
    NSArray *pdfArr = @[baidupdf,youtubepdf];
    NSString *AllpdfPath = [self joinPDF:pdfArr];
    
    NSURL *fileUrl = [NSURL URLWithString:AllpdfPath];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:fileUrl];
    
    [self.webView loadRequest:request];
    self.coverView.hidden = NO;
    
}

- (NSString *)joinPDF:(NSArray *)listOfPaths {
    // File paths
    NSString *fileName = @"ALL.pdf";
    NSString *pdfPathOutput = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    CFURLRef pdfURLOutput = (  CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:pdfPathOutput]);
    
    NSInteger numberOfPages = 0;
    // Create the output context
    CGContextRef writeContext = CGPDFContextCreateWithURL(pdfURLOutput, NULL, NULL);
    
    for (NSString *source in listOfPaths) {
        CFURLRef pdfURL = (  CFURLRef)CFBridgingRetain([[NSURL alloc] initFileURLWithPath:source]);
        
        //file ref
        CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL((CFURLRef) pdfURL);
        numberOfPages = CGPDFDocumentGetNumberOfPages(pdfRef);
        
        // Loop variables
        CGPDFPageRef page;
        CGRect mediaBox;
        
        // Read the first PDF and generate the output pages
        for (int i=1; i<=numberOfPages; i++) {
            page = CGPDFDocumentGetPage(pdfRef, i);
            mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
            CGContextBeginPage(writeContext, &mediaBox);
            CGContextDrawPDFPage(writeContext, page);
            CGContextEndPage(writeContext);
        }
        
        CGPDFDocumentRelease(pdfRef);
        CFRelease(pdfURL);
    }
    CFRelease(pdfURLOutput);
    
    // Finalize the output file
    CGPDFContextClose(writeContext);
    CGContextRelease(writeContext);
    
    return pdfPathOutput;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

typedef enum
{
	SimpleBarChartXLabelTypeVerticle,	// X-Axis labels will be rotated 90 degrees counter-clockwise
	SimpleBarChartXLabelTypeHorizontal, // X-Axis labels are horizontal (watch out that they don't over-lap! You can adjust the font through properties defined in this class)
	SimpleBarChartXLabelTypeAngled		// X-Axis labels are rotated 45 degrees counter-clockwise
} SimpleBarChartXLabelType;

typedef enum
{
	SimpleBarChartBarTextTypeRoof,		// Text is on top of the bars
	SimpleBarChartBarTextTypeTop,		// Text is inside the bars at the top
	SimpleBarChartBarTextTypeMiddle		// All text is aligned in the center of the shortest bar
} SimpleBarChartBarTextType;

@class SimpleBarChart;

@protocol SimpleBarChartDataSource <NSObject>

@required

- (NSUInteger)numberOfBarsInBarChart:(SimpleBarChart *)barChart;
- (CGFloat)barChart:(SimpleBarChart *)barChart valueForBarAtIndex:(NSUInteger)index;

@optional

- (UIColor *)barChart:(SimpleBarChart *)barChart colorForBarAtIndex:(NSUInteger)index;
- (NSString *)barChart:(SimpleBarChart *)barChart textForBarAtIndex:(NSUInteger)index;
- (NSString *)barChart:(SimpleBarChart *)barChart xLabelForBarAtIndex:(NSUInteger)index;

@end

@protocol SimpleBarChartDelegate <NSObject>

@optional

- (void)animationDidEndForBarChart:(SimpleBarChart *)barChart;

@end

@interface SimpleBarChart : UIView
{
	__weak id <SimpleBarChartDataSource> _dataSource;
	__weak id <SimpleBarChartDelegate> _delegate;

	NSNumber *_maxHeight;
	NSNumber *_minHeight;
	CGFloat _xLabelMaxHeight;
	NSMutableArray *_barHeights;
	NSMutableArray *_barLabels;
	NSMutableArray *_barTexts;
	NSInteger _topValue;
	NSInteger _numberOfBars;
	
	// Borders
	CALayer *_borderLayer;
	CAShapeLayer *_borderPathLayer;

	// Bars
	CALayer *_barLayer;
	NSMutableArray *_barPathLayers;

	// Grid
	CALayer *_gridLayer;
	CAShapeLayer *_gridPathLayer;

	// Labels
	UIView *_yLabelView;
	UIView *_xLabelView;
	CGFloat _xLabelRotation;

	UIView *_barTextView;
}

@property (weak, nonatomic) id <SimpleBarChartDataSource> dataSource;
@property (weak, nonatomic) id <SimpleBarChartDelegate> delegate;

@property (nonatomic, assign) CGFloat animationDuration; // How long the entire drawing will take
@property (nonatomic, assign) UIColor *chartBorderColor;

// Control Bars
@property (nonatomic, assign) CGFloat barWidth; // Space inbetween the bars
@property (nonatomic, assign) CGFloat barAlpha;
@property (nonatomic, assign) CGSize barShadowOffset;
@property (nonatomic, assign) UIColor *barShadowColor;
@property (nonatomic, assign) CGFloat barShadowAlpha;
@property (nonatomic, assign) CGFloat barShadowRadius;

// Control the Y-axis Labels
@property (nonatomic, assign) BOOL hasYLabels;
@property (nonatomic, strong) UIFont *yLabelFont;
@property (nonatomic, strong) UIColor *yLabelColor;

// Control the X-axis Labels
@property (nonatomic, strong) UIFont *xLabelFont;
@property (nonatomic, strong) UIColor *xLabelColor;
@property (nonatomic, assign) SimpleBarChartXLabelType xLabelType;

// Control the text near the bar
@property (nonatomic, strong) UIFont *barTextFont;
@property (nonatomic, strong) UIColor *barTextColor;
@property (nonatomic, assign) SimpleBarChartBarTextType barTextType;

// Control the grids
@property (nonatomic, assign) BOOL hasGrids;
@property (nonatomic, strong) UIColor *gridColor;
@property (nonatomic, assign) NSInteger incrementValue; // Every x draw a grid line (this also controls the height of the bar graph which is calculated to be the ceiling of this value (ex. if incrementValue = 10, the highest bar in the set is 23, then the top of the graph will be 30. Or.. incrementValue = 20 and _maxHeight = 46 then top will be 60. hasGrids only controls the displaying of the grid, not this calculation for the top.

- (void)reloadData;

@end

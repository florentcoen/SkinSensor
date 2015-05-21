//
//  SkinSensorDataViewController.m
//  Skin Sensor
//
//  Created by Florent-Valéry Coen on 15/05/15.
//  Copyright (c) 2015 Florent-Valéry Coen. All rights reserved.
//

#import "SkinSensorViewController.h"

#pragma mark - Heat Flow Constants

const double ARDUINO_AD_RESOLUTION = 1024;

const double P1 = 0.0023932036;
const double P2 = -0.1146469555;
const double P3 = 2.090311091;
const double P4 = -19.60117928;
const double P5 = 102.9477066;

const double VS = 4.967;

const double RREF = 10;

const double RBIAS_A0 = 0;
const double RBIAS_A1 = 0.03;

const double H_BLOOD_CONVECTION = 15;
const double H_AIR = 0;
const double K_POLYSTYRENE_FOAM = 0.033; // [W/mK]
const double T_POLYSTYRENE_FOAM = 0.9;
const double FOAM_ELEMENT_SIZE = 0.01; // [m]
const double FOAM_ELEMENT_THICKNESS = 0.0015; // [m]
const double BOLTZMAN_CONSTANT = 0.000000056703;
const double T_CONST = 273.15;

@implementation SkinSensorViewController

#pragma mark - Main Menu Controller Delegate
- (void) transferDataFromMainMenuToSubcontroller:(NSData *)newData{
    NSLog(@"RECEIVED DATA");
    
    const unsigned char *dataBuffer = (const unsigned char *)newData.bytes;
    
    NSUInteger          dataLength  = newData.length;
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 4)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"0X%02lx ", (unsigned long)dataBuffer[i]]];
    NSLog(@"%@",[NSString stringWithString:hexString]);
    
    [self processLastBLEMessage:newData];
    [self updateUIForCurrentValues];
    [self updateGraphs];
    [self updateLastBleMessageInterface:newData];
}


#pragma mark - UIViewController lifecycle methods

- (void) viewDidLoad{
    
    [super viewDidLoad];
    self.currentSkinSensorValues = [[skinSensorValues alloc] init];
    self.skinSensorHistory = [[NSMutableArray alloc] init];
    self.ambiantTemperature = 25;
    self.currentIndex = 0;
    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self initPlot];
}

#pragma mark - Sensor Data processing and displaying

- (void) processLastBLEMessage: (NSData *) newData{
    
    skinSensorValues *newSkinSensorValues = [[skinSensorValues alloc] init];
    
    const unsigned char *dataBuffer = (const unsigned char *)newData.bytes;
    uint16_t pinA0Value = [self make16BitsUnsignedFromByte:dataBuffer[1] and:dataBuffer[2]];
    uint16_t pinA1Value = [self make16BitsUnsignedFromByte:dataBuffer[4] and:dataBuffer[5]];
    
    NSLog(@"PINVALUE A0 %d PINVALUE A1 %d", pinA0Value,pinA1Value);
    
    [self compute:newSkinSensorValues WithHeatFlowModelBasedOnPinA0:pinA0Value andPinA1:pinA1Value];
    
    uint16_t sensorF0HumidityData = [self make16BitsUnsignedFromByte:dataBuffer[7] and:dataBuffer[8]];
    uint16_t sensorF0TemperatureData = [self make16BitsUnsignedFromByte:dataBuffer[9] and:dataBuffer[10]];
    newSkinSensorValues.sensorF0Humidity = [self computeHumidityValueOfHDC1000From:sensorF0HumidityData];
    newSkinSensorValues.sensorF0Temperature = [self computeTemperatureValueOfHDC1000From:sensorF0TemperatureData];
    
    uint16_t sensorF1HumidityData = [self make16BitsUnsignedFromByte:dataBuffer[12] and:dataBuffer[13]];
    uint16_t sensorF1TemperatureData = [self make16BitsUnsignedFromByte:dataBuffer[14] and:dataBuffer[15]];
    newSkinSensorValues.sensorF1Humidity = [self computeHumidityValueOfHDC1000From:sensorF1HumidityData];
    newSkinSensorValues.sensorF1Temperature = [self computeTemperatureValueOfHDC1000From:sensorF1TemperatureData];

    NSLog(@"TEMP F0 %d TEMP F1 %d", sensorF0TemperatureData, sensorF1TemperatureData);
    
    NSString *date = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                    dateStyle:NSDateFormatterShortStyle
                                                    timeStyle:NSDateFormatterMediumStyle];
    newSkinSensorValues.timeStamp = date;
    
    self.currentSkinSensorValues = newSkinSensorValues;
    [self.skinSensorHistory addObject:newSkinSensorValues];
    
    NSLog(@"size of history %d",[self.skinSensorHistory count]);
}

- (uint16_t) make16BitsUnsignedFromByte: (uint8_t) higherByte and: (uint8_t) lowerByte{
    uint16_t valueOn16Bits = lowerByte;
    valueOn16Bits = higherByte;
    valueOn16Bits = (valueOn16Bits << 8) | lowerByte;
    return valueOn16Bits;
    
}

- (void) compute: (skinSensorValues*) newSkinSensorValues WithHeatFlowModelBasedOnPinA0: (uint16_t) pinA0Value andPinA1: (uint16_t) pinA1Value{
    
    double voltageA0 = (double) pinA0Value / ARDUINO_AD_RESOLUTION * VS;
    double voltageA1 = (double) pinA1Value / ARDUINO_AD_RESOLUTION * VS;
    double resistorA0 = RREF *(VS/voltageA0 -1) + RBIAS_A0;
    double resistorA1 = RREF *(VS/voltageA1 -1) + RBIAS_A1;
    
    newSkinSensorValues.thermistorA0Temperature = (P1*pow(resistorA0, 4) + P2*pow(resistorA0, 3) + P3*pow(resistorA0, 2) + P4*resistorA0 + P5);
    newSkinSensorValues.thermistorA1Temperature = (P1*pow(resistorA1, 4) + P2*pow(resistorA1, 3) + P3*pow(resistorA1, 2) + P4*resistorA1 + P5);
    
    double QconductionPolystyrene = FOAM_ELEMENT_SIZE*FOAM_ELEMENT_SIZE*K_POLYSTYRENE_FOAM*(newSkinSensorValues.thermistorA1Temperature-newSkinSensorValues.thermistorA0Temperature)/FOAM_ELEMENT_THICKNESS;
    
    double Qconvexion = 2*(FOAM_ELEMENT_SIZE*FOAM_ELEMENT_THICKNESS+FOAM_ELEMENT_SIZE*FOAM_ELEMENT_THICKNESS)*H_AIR*(self.ambiantTemperature-newSkinSensorValues.thermistorA1Temperature);
    
    double Qradiation = 2*(FOAM_ELEMENT_SIZE*FOAM_ELEMENT_THICKNESS+FOAM_ELEMENT_SIZE*FOAM_ELEMENT_THICKNESS)*BOLTZMAN_CONSTANT*T_POLYSTYRENE_FOAM*(pow(self.ambiantTemperature+T_CONST, 4) - pow(newSkinSensorValues.thermistorA1Temperature+T_CONST, 4));
    
    newSkinSensorValues.bodyTemperature = (H_BLOOD_CONVECTION*(newSkinSensorValues.thermistorA0Temperature+T_CONST)*FOAM_ELEMENT_SIZE*FOAM_ELEMENT_SIZE-QconductionPolystyrene-Qconvexion-Qradiation)/(H_BLOOD_CONVECTION*FOAM_ELEMENT_SIZE*FOAM_ELEMENT_SIZE)-T_CONST;
    
}

- (void) applyHeatFlowModelFromResistorA0: (double) resistorA0 andResistorA1: (double) resistorA1 {
}

- (double) computeTemperatureValueOfHDC1000From: (uint16_t) temperatureData{
    
    return (double) temperatureData / 65536.0 * 165.0 -40.0;
}

- (double) computeHumidityValueOfHDC1000From: (uint16_t) humidityData{
    
    return (double) humidityData / (double) 65536 * (double) 100;
}

- (void) updateUIForCurrentValues{
    
    self.bodyTemperatureLabel.text = [NSString stringWithFormat:@"%.02f°C",self.currentSkinSensorValues.bodyTemperature];
    self.thermistorA0TemperatureLabel.text = [NSString stringWithFormat:@"%.02f°C",self.currentSkinSensorValues.thermistorA0Temperature];
    self.thermistorA1TemperatureLabel.text = [NSString stringWithFormat:@"%.02f°C",self.currentSkinSensorValues.thermistorA1Temperature];
    
    self.sensorF0TemperatureLabel.text = [NSString stringWithFormat:@"%.02f°C",self.currentSkinSensorValues.sensorF0Temperature];
    self.sensorF0HumidityLabel.text = [NSString stringWithFormat:@"%.02f %%",self.currentSkinSensorValues.sensorF0Humidity];
    self.sensorF1TemperatureLabel.text = [NSString stringWithFormat:@"%.02f°C",self.currentSkinSensorValues.sensorF1Temperature];
    self.sensorF1HumidityLabel.text = [NSString stringWithFormat:@"%.02f %%",self.currentSkinSensorValues.sensorF1Humidity ];
}

- (void) updateLastBleMessageInterface: (NSData*) newData{
    
    const unsigned char *dataBuffer = (const unsigned char *)newData.bytes;
    NSUInteger          dataLength  = newData.length;
    
    if (dataLength == 16) {
        NSMutableString     *hexStringThermistorA0 = [[NSMutableString alloc] init];
        for (int i = 0; i < 3; i++) {
            [hexStringThermistorA0 appendString:[NSString stringWithFormat:@"0X%02lx ", (unsigned long)dataBuffer[i]]];
        }
        self.thermistorA0MessageLabel.text = [NSString stringWithString:hexStringThermistorA0];
        
        NSMutableString     *hexStringThermistorA1 = [[NSMutableString alloc] init];
        for (int i = 3; i < 6; i++) {
            [hexStringThermistorA1 appendString:[NSString stringWithFormat:@"0X%02lx ", (unsigned long)dataBuffer[i]]];
        }
        self.thermistorA1MessageLabel.text = hexStringThermistorA1;
        
        NSMutableString     *hexStringSensorF0 = [[NSMutableString alloc] init];
        for (int i = 6; i < 11; i++) {
            [hexStringSensorF0 appendString:[NSString stringWithFormat:@"0X%02lx ", (unsigned long)dataBuffer[i]]];
        }
        self.sensorF0MessageLabel.text = hexStringSensorF0;
        
        NSMutableString     *hexStringSensorF1 = [[NSMutableString alloc] init];
        for (int i = 11; i < 16; i++) {
            [hexStringSensorF1 appendString:[NSString stringWithFormat:@"0X%02lx ", (unsigned long)dataBuffer[i]]];
        }
        self.sensorF1MessageLabel.text = hexStringSensorF1;
    }
}

#pragma mark - Chart behavior

- (void) updateGraphs{
    CPTGraph *theGraph = self.hostViewTemperature.hostedGraph;
    CPTGraph *humidityGraph = self.hostViewHumidity.hostedGraph;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)theGraph.defaultPlotSpace;
    CPTXYPlotSpace *humidityPlotSpace = (CPTXYPlotSpace *)humidityGraph.defaultPlotSpace;
    NSUInteger location       = (self.currentIndex >= 9 ? self.currentIndex - 10 + 2 : 0);
    
    [self.hostViewTemperature.hostedGraph reloadData];
    [self.hostViewHumidity.hostedGraph reloadData];
    
    CPTPlotRange *newRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(location)
                                                          length:CPTDecimalFromUnsignedInteger(10-1)];
    plotSpace.xRange = newRange;
    humidityPlotSpace.xRange = newRange;
    self.currentIndex++;
}

-(void)initPlot {
    self.hostViewTemperature.allowPinchScaling = NO;
    self.hostViewHumidity.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostViewTemperature.bounds];
    CPTGraph *humidityGraph = [[CPTXYGraph alloc] initWithFrame:self.hostViewHumidity.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    [humidityGraph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.plotAreaFrame.borderLineStyle = nil;
    humidityGraph.plotAreaFrame.borderLineStyle = nil;
    self.hostViewTemperature.hostedGraph = graph;
    self.hostViewHumidity.hostedGraph = humidityGraph;
    // 4 - Set padding for plot area
    [humidityGraph.plotAreaFrame setPaddingLeft:40.0f];
    [humidityGraph.plotAreaFrame setPaddingRight:10.0f];
    [graph.plotAreaFrame setPaddingLeft:40.0f];
    [graph.plotAreaFrame setPaddingRight:10.0f];
    //[graph.plotAreaFrame setPaddingBottom:10.0f];
}

-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostViewTemperature.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(20) length:CPTDecimalFromInt(25)];
    
    CPTGraph *humidityGraph = self.hostViewHumidity.hostedGraph;
    CPTXYPlotSpace *humidityPlotSpace = (CPTXYPlotSpace*) humidityGraph.defaultPlotSpace;
    humidityPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(100)];
    
    // 2 - Create the five plots
    CPTScatterPlot *bodyTemperaturePlot = [[CPTScatterPlot alloc] init];
    bodyTemperaturePlot.dataSource = self;
    bodyTemperaturePlot.identifier = @"body temperature identifier";
    CPTColor *bodyTemperatureColor = [CPTColor redColor];
    [graph addPlot:bodyTemperaturePlot toPlotSpace:plotSpace];
    
    CPTScatterPlot *thermistorA0Plot = [[CPTScatterPlot alloc] init];
    thermistorA0Plot.dataSource = self;
    thermistorA0Plot.identifier = @"thermistor A0 identifier";
    CPTColor *thermistorA0Color = [CPTColor greenColor];
    [graph addPlot:thermistorA0Plot toPlotSpace:plotSpace];
    
    CPTScatterPlot *thermistorA1Plot = [[CPTScatterPlot alloc] init];
    thermistorA1Plot.dataSource = self;
    thermistorA1Plot.identifier = @"thermistor A1 identifier";
    CPTColor *thermistorA1Color = [CPTColor blueColor];
    [graph addPlot:thermistorA1Plot toPlotSpace:plotSpace];
    
    CPTScatterPlot *humidityF0Plot = [[CPTScatterPlot alloc] init];
    humidityF0Plot.dataSource = self;
    humidityF0Plot.identifier = @"humidity F0 identifier";
    CPTColor *humidityF0Color = [CPTColor blueColor];
    [humidityGraph addPlot:humidityF0Plot toPlotSpace:humidityPlotSpace];
    
    CPTScatterPlot *humidityF1Plot = [[CPTScatterPlot alloc] init];
    humidityF1Plot.dataSource = self;
    humidityF1Plot.identifier = @"humidity F1 identifier";
    CPTColor *humidityF1Color = [CPTColor redColor];
    [humidityGraph addPlot:humidityF1Plot toPlotSpace:humidityPlotSpace];
    
    // 3 - Set up plot space
    //[plotSpace scaleToFitPlots:[NSArray arrayWithObjects:bodyTemperaturePlot, thermistorA0Plot, thermistorA1Plot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    
    xRange = [humidityPlotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    humidityPlotSpace.xRange = xRange;
    
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    
    yRange = [humidityPlotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    humidityPlotSpace.yRange = yRange;
    
    // 4 - Create styles and symbols
    CPTMutableLineStyle *bodyTemperatureLineStyle = [bodyTemperaturePlot.dataLineStyle mutableCopy];
    bodyTemperatureLineStyle.lineWidth = 2.0;
    bodyTemperatureLineStyle.lineColor = bodyTemperatureColor;
    bodyTemperaturePlot.dataLineStyle = bodyTemperatureLineStyle;
    CPTMutableLineStyle *bodyTemperatureSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    bodyTemperatureSymbolLineStyle.lineColor = bodyTemperatureColor;
    CPTPlotSymbol *bodyTemperatureSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    bodyTemperatureSymbol.fill = [CPTFill fillWithColor:bodyTemperatureColor];
    bodyTemperatureSymbol.lineStyle = bodyTemperatureSymbolLineStyle;
    bodyTemperatureSymbol.size = CGSizeMake(6.0f, 6.0f);
    bodyTemperaturePlot.plotSymbol = bodyTemperatureSymbol;
    
    CPTMutableLineStyle *thermistorA0LineStyle = [thermistorA0Plot.dataLineStyle mutableCopy];
    thermistorA0LineStyle.lineWidth = 2.0;
    thermistorA0LineStyle.lineColor = thermistorA0Color;
    thermistorA0Plot.dataLineStyle = thermistorA0LineStyle;
    CPTMutableLineStyle *thermistorA0SymbolLineStyle = [CPTMutableLineStyle lineStyle];
    thermistorA0SymbolLineStyle.lineColor = thermistorA0Color;
    CPTPlotSymbol *thermistorA0Symbol = [CPTPlotSymbol diamondPlotSymbol];
    thermistorA0Symbol.fill = [CPTFill fillWithColor:thermistorA0Color];
    thermistorA0Symbol.lineStyle = thermistorA0SymbolLineStyle;
    thermistorA0Symbol.size = CGSizeMake(6.0f, 6.0f);
    thermistorA0Plot.plotSymbol = thermistorA0Symbol;
    
    CPTMutableLineStyle *thermistorA1LineStyle = [thermistorA1Plot.dataLineStyle mutableCopy];
    thermistorA1LineStyle.lineWidth = 2.0;
    thermistorA1LineStyle.lineColor = thermistorA1Color;
    thermistorA1Plot.dataLineStyle = thermistorA1LineStyle;
    CPTMutableLineStyle *thermistorA1SymbolLineStyle = [CPTMutableLineStyle lineStyle];
    thermistorA1SymbolLineStyle.lineColor = thermistorA1Color;
    CPTPlotSymbol *thermistorA1Symbol = [CPTPlotSymbol diamondPlotSymbol];
    thermistorA1Symbol.fill = [CPTFill fillWithColor:thermistorA1Color];
    thermistorA1Symbol.lineStyle = thermistorA1SymbolLineStyle;
    thermistorA1Symbol.size = CGSizeMake(6.0f, 6.0f);
    thermistorA1Plot.plotSymbol = thermistorA1Symbol;
    
    CPTMutableLineStyle *humidityF0LineStyle = [humidityF0Plot.dataLineStyle mutableCopy];
    humidityF0LineStyle.lineWidth = 2.0;
    humidityF0LineStyle.lineColor = humidityF0Color;
    humidityF0Plot.dataLineStyle = humidityF0LineStyle;
    CPTMutableLineStyle *humidityF0SymbolLineStyle = [CPTMutableLineStyle lineStyle];
    humidityF0SymbolLineStyle.lineColor = humidityF0Color;
    CPTPlotSymbol *humidityF0Symbol = [CPTPlotSymbol ellipsePlotSymbol];
    humidityF0Symbol.fill = [CPTFill fillWithColor:humidityF0Color];
    humidityF0Symbol.lineStyle = humidityF0SymbolLineStyle;
    humidityF0Symbol.size = CGSizeMake(6.0f, 6.0f);
    humidityF0Plot.plotSymbol = humidityF0Symbol;
    
    CPTMutableLineStyle *humidityF1LineStyle = [humidityF1Plot.dataLineStyle mutableCopy];
    humidityF1LineStyle.lineWidth = 2.0;
    humidityF1LineStyle.lineColor = humidityF1Color;
    humidityF1Plot.dataLineStyle = humidityF1LineStyle;
    CPTMutableLineStyle *humidityF1SymbolLineStyle = [CPTMutableLineStyle lineStyle];
    humidityF1SymbolLineStyle.lineColor = humidityF1Color;
    CPTPlotSymbol *humidityF1Symbol = [CPTPlotSymbol diamondPlotSymbol];
    humidityF1Symbol.fill = [CPTFill fillWithColor:humidityF1Color];
    humidityF1Symbol.lineStyle = humidityF1SymbolLineStyle;
    humidityF1Symbol.size = CGSizeMake(6.0f, 6.0f);
    humidityF1Plot.plotSymbol = humidityF1Symbol;
}

-(void)configureAxes {

    // 1 - Create styles
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.fontName = @"Helvetica";
    axisTextStyle.fontSize = 11.0f;
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor blackColor];
    gridLineStyle.lineWidth = 1.0f;
    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostViewTemperature.hostedGraph.axisSet;
    CPTXYAxisSet *humidityAxisSet = (CPTXYAxisSet *) self.hostViewHumidity.hostedGraph.axisSet;
    
    // 3 - Configure x-axis
    axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(@"20");
    humidityAxisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    
    CPTAxis *x = axisSet.xAxis;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(25)];
    x.hidden = YES;
    
    CPTAxis *xHumditiy = humidityAxisSet.xAxis;
    xHumditiy.axisLineStyle = axisLineStyle;
    xHumditiy.labelingPolicy = CPTAxisLabelingPolicyNone;
    xHumditiy.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(25)];
    xHumditiy.hidden = YES;
    
    // 4 - Configure y-axis
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    humidityAxisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    
    CPTAxis *y = axisSet.yAxis;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(20) length:CPTDecimalFromFloat(25)];
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = -33.0f; //16
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.tickDirection = CPTSignPositive;
    y.minorTickLineStyle = tickLineStyle;
    axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
    CPTAxis *yHumditiy = humidityAxisSet.yAxis;
    yHumditiy.axisLineStyle = axisLineStyle;
    yHumditiy.majorGridLineStyle = gridLineStyle;
    yHumditiy.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    yHumditiy.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(100)];
    yHumditiy.labelTextStyle = axisTextStyle;
    yHumditiy.labelOffset = -33.0f; //16
    yHumditiy.majorTickLineStyle = axisLineStyle;
    yHumditiy.majorTickLength = 4.0f;
    yHumditiy.tickDirection = CPTSignPositive;
    yHumditiy.minorTickLineStyle = tickLineStyle;
    humidityAxisSet.yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
}


#pragma mark CorePlot Delegate

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    return [self.skinSensorHistory count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    NSInteger numberOfDataPoints = [self.skinSensorHistory count];
    
    switch (fieldEnum) {
            
        case CPTScatterPlotFieldX:
            if (index < numberOfDataPoints) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
            
        case CPTScatterPlotFieldY:
            if (index < numberOfDataPoints) {
                if ([plot.identifier isEqual:@"body temperature identifier"]) {
                    return [NSNumber numberWithDouble:[[self.skinSensorHistory objectAtIndex:index] bodyTemperature]];
                }
                else if([plot.identifier isEqual:@"thermistor A0 identifier"]) {
                    return [NSNumber numberWithDouble:[[self.skinSensorHistory objectAtIndex:index] thermistorA0Temperature]];
                }
                else if([plot.identifier isEqual:@"thermistor A1 identifier"]) {
                    return [NSNumber numberWithDouble:[[self.skinSensorHistory objectAtIndex:index] thermistorA1Temperature]];
                }
                else if([plot.identifier isEqual:@"humidity F0 identifier"]) {
                    return [NSNumber numberWithDouble:[[self.skinSensorHistory objectAtIndex:index] sensorF0Humidity]];
                }
                else if([plot.identifier isEqual:@"humidity F1 identifier"]) {
                    return [NSNumber numberWithDouble:[[self.skinSensorHistory objectAtIndex:index] sensorF1Humidity]];
                }
            }
            break;
    }
    
    return [NSDecimalNumber zero];
}

- (IBAction)inputTimerPeriod:(id)sender {
}

- (IBAction)inputAmbiantTemperature:(id)sender {
}


#pragma mark Mail Composer Delegate

- (IBAction)pressedMailButton:(id)sender {
    NSLog(@"Mail button pressed");
    NSMutableString *sensorData = [[NSMutableString alloc] init];
    [sensorData appendString:@"Timestamp, Body Temperature, Thermistor A0, Thermistor A1, HDC1000-F0 Humidity, HDC1000-F0 Temperature, HDC1000-F1 Humidity, HDC1000-F1 Temperature\n"];
    for (int i=0; i < self.skinSensorHistory.count; i++) {
        skinSensorValues *scannedValues = [self.skinSensorHistory objectAtIndex:i];
        [sensorData appendFormat:@"%@,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f\n",scannedValues.timeStamp,scannedValues.bodyTemperature,scannedValues.thermistorA0Temperature,scannedValues.thermistorA1Temperature,scannedValues.sensorF0Humidity,scannedValues.sensorF0Temperature,scannedValues.sensorF1Humidity,scannedValues.sensorF1Temperature];
    }
    
    MFMailComposeViewController *mFMCVC = [[MFMailComposeViewController alloc]init];
    if (mFMCVC) {
        if ([MFMailComposeViewController canSendMail]) {
            mFMCVC.mailComposeDelegate = self;
            [mFMCVC setSubject:@"Data from Skin Sensor"];
            [mFMCVC setMessageBody:@"Data from Skin Sensor 1.0" isHTML:NO];
            [self presentViewController:mFMCVC animated:YES completion:nil];
            
            [mFMCVC addAttachmentData:[sensorData dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/csv" fileName:@"Skin_Sensor_Log.csv"];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mail error" message:@"Device has not been set up to send mail" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end

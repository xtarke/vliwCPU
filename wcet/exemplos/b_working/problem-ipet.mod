# variables

var d25_0>=0;
var d0_1>=0;
var d1_2>=0;
var d2_3>=0;
var d3_4>=0;
var d9_5>=0;
var d4_6>=0;
var d5_6>=0;
var d6_7>=0;
var d10_8>=0;
var d7_9lfm>=0;
var d7_9lh>=0;
var d8_9lah>=0;
var d9_10>=0;
var d6_11>=0;
var d11_12>=0;
var d12_13>=0;
var d18_14>=0;
var d13_15>=0;
var d14_15>=0;
var d15_16fm>=0;
var d15_16h>=0;
var d20_17>=0;
var d21_17>=0;
var d16_18>=0;
var d17_18>=0;
var d18_19fm>=0;
var d18_19h>=0;
var d19_20fm>=0;
var d19_20h>=0;
var d19_21fm>=0;
var d19_21h>=0;
var d15_22>=0;
var d22_23>=0;
var d23_24>=0;
var dstart25=1;
var d24_26>=0;
var dend26=1;

# objetive (compensating a pipeline with length 5)

maximize wcet: d25_0*45 - d25_0*4 + d0_1*51 - d0_1*4 + d1_2*9 - d1_2*4 + d2_3*9 - d2_3*4 + d3_4*47 - d3_4*4 + d9_5*8 - d9_5*4 + d4_6*45 - d4_6*4 + d5_6*9 - d5_6*4 + d6_7*7 - d6_7*4 + d10_8*25 - d10_8*4 + d7_9lfm*45 - d7_9lfm*4 + d7_9lh*9 - d7_9lh*4 + d8_9lah*9 - d8_9lah*4 + d9_10*6 - d9_10*4 + d6_11*8 - d6_11*4 + d11_12*10 - d11_12*4 + d12_13*50 - d12_13*4 + d18_14*8 - d18_14*4 + d13_15*9 - d13_15*4 + d14_15*9 - d14_15*4 + d15_16fm*43 - d15_16fm*4 + d15_16h*7 - d15_16h*4 + d20_17*8 - d20_17*4 + d21_17*8 - d21_17*4 + d16_18*9 - d16_18*4 + d17_18*9 - d17_18*4 + d18_19fm*61 - d18_19fm*4 + d18_19h*25 - d18_19h*4 + d19_20fm*67 - d19_20fm*4 + d19_20h*31 - d19_20h*4 + d19_21fm*103 - d19_21fm*4 + d19_21h*31 - d19_21h*4 + d15_22*115 - d15_22*4 + d22_23*12 - d22_23*4 + d23_24*9 - d23_24*4 + dstart25*43 - dstart25*4 + d24_26*5;

# program sequence constraints (limiting loops) <2>

s.t. x0: d25_0 <= 1;
s.t. x1: d0_1 <= 1;
s.t. x2: d1_2 <= 1;
s.t. x3: d2_3 <= 1;
s.t. x4: d3_4 <= 1;
s.t. x5: d9_5 <= 10;
s.t. x6: d4_6 + d5_6 <= 11;
s.t. x7: d6_7 <= 10;
s.t. x8: d10_8 <= 100;
s.t. x9: d7_9lfm + d7_9lh + d8_9lah <= 110;
s.t. x10: d9_10 <= 100;
s.t. x11: d6_11 <= 1;
s.t. x12: d11_12 <= 1;
s.t. x13: d12_13 <= 1;
s.t. x14: d18_14 <= 10;
s.t. x15: d13_15 + d14_15 <= 11;
s.t. x16: d15_16fm + d15_16h <= 10;
s.t. x17: d20_17 + d21_17 <= 100;
s.t. x18: d16_18 + d17_18 <= 110;
s.t. x19: d18_19fm + d18_19h <= 100;
s.t. x20: d19_20fm + d19_20h <= 100;
s.t. x21: d19_21fm + d19_21h <= 100;
s.t. x22: d15_22 <= 1;
s.t. x23: d22_23 <= 1;
s.t. x24: d23_24 <= 1;
s.t. x25: dstart25 = 1;
s.t. x26: d24_26 <= 1;

# program sequence constraints (flow conservation) <2>

s.t. xc0: d25_0 - d0_1 = 0;
s.t. xc1: d0_1 - d1_2 = 0;
s.t. xc2: d1_2 - d2_3 = 0;
s.t. xc3: d2_3 - d3_4 = 0;
s.t. xc4: d3_4 - d4_6 = 0;
s.t. xc5: d9_5 - d5_6 = 0;
s.t. xc6: d4_6 + d5_6 - d6_7 - d6_11 = 0;
s.t. xc7: d6_7 - d7_9lfm - d7_9lh = 0;
s.t. xc8: d10_8 - d8_9lah = 0;
s.t. xc9: d7_9lfm + d7_9lh + d8_9lah - d9_5 - d9_10 = 0;
s.t. xc10: d9_10 - d10_8 = 0;
s.t. xc11: d6_11 - d11_12 = 0;
s.t. xc12: d11_12 - d12_13 = 0;
s.t. xc13: d12_13 - d13_15 = 0;
s.t. xc14: d18_14 - d14_15 = 0;
s.t. xc15: d13_15 + d14_15 - d15_16fm - d15_16h - d15_22 = 0;
s.t. xc16: d15_16fm + d15_16h - d16_18 = 0;
s.t. xc17: d20_17 + d21_17 - d17_18 = 0;
s.t. xc18: d16_18 + d17_18 - d18_14 - d18_19fm - d18_19h = 0;
s.t. xc19: d18_19fm + d18_19h - d19_20fm - d19_20h - d19_21fm - d19_21h = 0;
s.t. xc20: d19_20fm + d19_20h - d20_17 = 0;
s.t. xc21: d19_21fm + d19_21h - d21_17 = 0;
s.t. xc22: d15_22 - d22_23 = 0;
s.t. xc23: d22_23 - d23_24 = 0;
s.t. xc24: d23_24 - d24_26 = 0;
s.t. xc25: dstart25 - d25_0 = 0;
s.t. xc26: d24_26 - dend26 = 0;

# program cache constraints 

s.t. xcache9: d7_9lfm <= 1;
s.t. xcache16: d15_16fm <= 1;
s.t. xcache19: d18_19fm <= 10;
s.t. xcache20: d19_20fm <= 10;
s.t. xcache21: d19_21fm <= 10;

# program autoloop constraints

s.t. xal6: d4_6*10 - d6_7 = 0;
s.t. xal9: d7_9lfm*10 + d7_9lh*10 - d9_10 = 0;
s.t. xal15: d13_15*10 - d15_16fm - d15_16h = 0;
s.t. xal18: d16_18*10 - d18_19fm - d18_19h = 0;

solve;
display wcet;
end;

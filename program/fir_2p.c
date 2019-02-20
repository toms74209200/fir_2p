/* 
 * Project: FIR coefficient generator base on 2 power
 * Author: T.Suzuki
 *
 * Created on 2018/12/04
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

double h_impls(float);
double w_hamming(float);

unsigned int taps;
float taps_half;
unsigned int bit_width;
double ratio_fc;

void main(void) {
// Setting input
	printf("Please enter taps : ");
	scanf("%u", &taps);
	taps_half = (taps+1)/2;
	printf("Please enter bit width : ");
	scanf("%u", &bit_width);
//	printf("Please enter cut-off frequency ratio : ");
//	scanf("%f", &ratio_fc);

	ratio_fc = 0.1;

	double h_window[taps];
	for (signed int i=0;i<=taps;i++) {
		if (i == taps_half)
			h_window[i] = 2*ratio_fc;
		else
			h_window[i] = h_impls(i-taps_half)*w_hamming(i-taps_half);
	}


	for (int i=0;i<=taps-1;i++) {
		printf("%f", h_window[i]);
		printf(",");
	}
		printf("%f", h_window[taps]);
		printf("\n");
		

// Make plot data file
	FILE *data, *gp;
	char *data_file;
	double x, y;

	data_file="out.dat";
	data = fopen(data_file,"w");
		for(int i=0; i<=taps; i++){
			x = i;
			y = h_window[i];
			fprintf(data,"%f\t%f\n", x ,y);
		}
	fclose(data);

// Launch gnuplot
	gp = popen("DISPLAY=localhost:0.0 gnuplot -persist","w");
	fprintf(gp, "plot \"%s\" w l \n",data_file);
	pclose(gp);

double h_2p[taps];
double residual[taps];
double residual_min[taps];

// 2 power coefficient
	for (int i=0; i<=taps; i++) {
		residual_min[i] = 1.0;
		printf("%f\n", h_window[i]);
		for (int j=0; j<=bit_width-1; j++) {
			if (h_window[i] == 0.0) {
				h_2p[i] = 0;
				printf("break:%u\n", j);
				break;
			} else if (h_window[i] > 0) {
				residual[i] = h_window[i] - pow(2,-j);
				if (pow(residual[i],2) < pow(residual_min[i],2)) {
					h_2p[i] = j;
					residual_min[i] = residual[i];
					printf("%u,", j);
					printf("%f\n", residual_min[i]);
				}
			} else {
				residual[i] = h_window[i] + pow(2,-j);
				if (pow(residual[i],2) < pow(residual_min[i],2)) {
					h_2p[i] = - j;
					residual_min[i] = residual[i];
					printf("%u,", j);
					printf("%f\n", residual_min[i]);
				}
			}
		}
	}

	for (int i=0;i<=taps-1;i++) {
		if (h_2p[i] == 0)
			printf("%f", 0.0);
		else if (h_2p[i] > 0)
			printf("2^-%f", h_2p[i]);
		else
			printf("-2^-%f", -h_2p[i]);
		printf(",");
	}
		if (h_2p[taps] == 0)
			printf("%f", 0.0);
		else if (h_2p[taps] > 0)
			printf("2^-%f", h_2p[taps]);
		else
			printf("-2^-%f", -h_2p[taps]);
		printf("\n");

	data_file="out_2p.dat";
	data = fopen(data_file,"w");
		for(int i=0; i<=taps; i++){
			x = i;
			if (h_2p[i] == 0)
				y = 0;
			else if (h_2p[i] > 0)
				y = pow(2,-(h_2p[i]));
			else
				y = -pow(2,(h_2p[i]));
			
			fprintf(data,"%f\t%f\n", x ,y);
		}
	fclose(data);

// Launch gnuplot
	gp = popen("DISPLAY=localhost:0.0 gnuplot -persist","w");
	fprintf(gp, "plot \"%s\" w l \n",data_file);
	pclose(gp);

// Write coefficient file
	data = fopen("coef.dat","w");
		for(int i=0; i<=taps; i++){
			if (h_2p[i] == 0)
				fprintf(data,"\"%f\",\n", 0.0);
			else if (h_2p[i] > 0)
				fprintf(data,"\"%f\",\n", h_2p[i]);
			else
				fprintf(data,"\"-%f\",\n", -h_2p[i]);
		}
	fclose(data);

}

// Impulse response
double h_impls(float n) {
	return sin(2*n*M_PI*ratio_fc)/(n*M_PI);
}

// Hamming window function
double w_hamming(float n) {
	return (25./46.)+(21./46.)*cos(n*M_PI/taps_half);
} 


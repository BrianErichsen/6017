//Author: Brian Erichsen Fagundes
//CS6017 - Summer - 2014
// Timing experiment of KNN application with different data structures

import std.stdio;
import std.datetime;
import std.csv;
import std.random;
import std.conv;

import common;
import dumbknn;
import bucketknn;
import quadtree;
import kdtree;

alias P2 = Point!2;

void main()
{
    //Parameters for testing
    int[] k_values = [1, 5, 10, 20, 25];
    int[] N_values = [100, 1000, 5000, 10000, 20000];
    int trials = 3;
    int num_queries = 100;
    int num_reps = 50;
    // Opens csv file for writing - appending the data
    File file = File("timing2.csv", "a");
    file.writefln("testType,structType,k,N,D,distribution,timing,trial");

    //BucketKNN Gaussian for varying k
    foreach (k; k_values) {
        for (int i = 0; i < trials; i++) {
            long totalTime = 0;
            auto trainingPoints = getGaussianPoints!2(1000);
            auto testingPoints = getUniformPoints!2(100);
            auto bucket = BucketKNN!2(trainingPoints, cast(int)pow(1000/64, 1.0/2));
            auto sw = StopWatch(AutoStart.no);
            for (int round = 0; round < num_reps; round++) {
                sw.start;
                foreach (const ref qp; testingPoints) {
                    bucket.knnQuery(qp, k);
                }
                sw.stop;
                totalTime += sw.peek.total!"usecs";
            }
            long averageTime = totalTime/num_reps;
            file.writeln("k,bucket,"~(to!string(k))~",1000,2,G,"~(to!string(averageTime))~","~(to!string(i + 1)));
        }
    }
    //Bucket KNN Gaussian varying D
    static foreach (dim; 1 .. 8) {{
        for (int i = 0; i < trials; i++) {
            long totalTime = 0;
            auto trainingPoints = getGaussianPoints!dim(1000);
            auto testingPoints = getUniformPoints!dim(100);
            auto bucket = BucketKNN!dim(trainingPoints, cast(int)pow(1000/64, 1.0/dim));
            auto sw = StopWatch(AutoStart.no);
            for (int round = 0; round < num_reps; round++) {
                sw.start;
                foreach (const ref qp; testingPoints) {
                    bucket.knnQuery(qp, 10);
                }
                sw.stop;
                totalTime += sw.peek.total!"usecs";
            }
            long averageTime = totalTime/num_reps;
            file.writeln("d,bucket,10,1000,"~(to!string(dim))~",G,"~(to!string(averageTime))~","~(to!string(i + 1)));
        }
    }}
    //Bucket Gaussian varying N
    foreach (n; N_values) {
        for (int i = 0; i < trials; i++) {
            long totalTime = 0;
            auto trainingPoints = getGaussianPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto bucket = BucketKNN!2(trainingPoints, cast(int)pow(1000/64, 1.0/2));
            auto sw = StopWatch(AutoStart.no);
            int k = 10;
            for (int round = 0; round < num_reps; round++) {
                sw.start;
                foreach (const ref qp; testingPoints) {
                    bucket.knnQuery(qp, k);
                }
                sw.stop;
                totalTime += sw.peek.total!"usecs";
            }
            long averageTime = totalTime/num_reps;
            file.writeln("n,bucket,10,"~(to!string(n))~",2,G,"~(to!string(averageTime))~","~(to!string(i + 1)));
        }
    }
    //Bucket KNN Gaussian Varying K and N
    for (int index = 0; index < k_values.length; index++) {
        int k = k_values[index];
        int n = N_values[index];
        for (int i = 0; i < trials; i++) {
            long totalTime = 0;
            auto trainingPoints = getGaussianPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto bucket = BucketKNN!2(trainingPoints, cast(int)pow(1000/64, 1.0/2));
            auto sw = StopWatch(AutoStart.no);
            for (int round = 0; round < num_reps; round++) {
                sw.start;
                foreach (const ref qp; testingPoints) {
                    bucket.knnQuery(qp, k);
                }
                sw.stop;
                totalTime += sw.peek.total!"usecs";
            }
            long averageTime = totalTime/num_reps;
            file.writeln("kn,bucket,"~(to!string(k))~","~(to!string(n))~",2,G,"~(to!string(averageTime))~","~(to!string(i + 1)));
        }
    }
    //KNN uniform varying k
    foreach (k; k_values) {
        for (int i = 0; i < trials; i++) {
            long totalTime = 0;
            auto trainingPoints = getUniformPoints!2(1000);
            auto testingPoints = getUniformPoints!2(100);
            auto bucket = BucketKNN!2(trainingPoints, cast(int)pow(1000/64, 1.0/2));
            auto sw = StopWatch(AutoStart.no);
            for (int round = 0; round < num_reps; round++) {
                sw.start;
                foreach (const ref qp; testingPoints) {
                    bucket.knnQuery(qp, k);
                }
                sw.stop;
                totalTime += sw.peek.total!"usecs";
            }
            long averageTime = totalTime/num_reps;
            file.writeln("k,bucket,"~(to!string(k))~",1000,2,U,"~(to!string(averageTime))~","~(to!string(i + 1)));
        }
    }
    // KNN uniform varying D
    static foreach (dim; 1 .. 8) {{
        for (int i = 0; i < trials; i++) {
            long totalTime = 0;
            auto trainingPoints = getUniformPoints!dim(1000);
            auto testingPoints = getUniformPoints!dim(100);
            auto bucket = BucketKNN!dim(trainingPoints, cast(int)pow(1000/64, 1.0/dim));
            auto sw = StopWatch(AutoStart.no);
            for (int round = 0; round < num_reps; round++) {
                sw.start;
                foreach (const ref qp; testingPoints) {
                    bucket.knnQuery(qp, 10);
                }
                sw.stop;
                totalTime += sw.peek.total!"usecs";
            }
            long averageTime = totalTime/num_reps;
            file.writeln("d,bucket,10,1000,"~(to!string(dim))~",U,"~(to!string(averageTime))~","~(to!string(i + 1)));
        }
    }}
    //Bucket Uniform varying N
    foreach (n; N_values) {
        for (int i = 0; i < trials; i++) {
            long totalTime = 0;
            auto trainingPoints = getUniformPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto bucket = BucketKNN!2(trainingPoints, cast(int)pow(1000/64, 1.0/2));
            auto sw = StopWatch(AutoStart.no);
            int k = 10;
            for (int round = 0; round < num_reps; round++) {
                sw.start;
                foreach (const ref qp; testingPoints) {
                    bucket.knnQuery(qp, k);
                }
                sw.stop;
                totalTime += sw.peek.total!"usecs";
            }
            long averageTime = totalTime/num_reps;
            file.writeln("n,bucket,10,"~(to!string(n))~",2,U,"~(to!string(averageTime))~","~(to!string(i + 1)));
        }
    }
    //Bucket KNN Uniform Varying K and N
    for (int index = 0; index < k_values.length; index++) {
        int k = k_values[index];
        int n = N_values[index];
        for (int i = 0; i < trials; i++) {
            long totalTime = 0;
            auto trainingPoints = getUniformPoints!2(n);
            auto testingPoints = getUniformPoints!2(n/100);
            auto bucket = BucketKNN!2(trainingPoints, cast(int)pow(1000/64, 1.0/2));
            auto sw = StopWatch(AutoStart.no);
            for (int round = 0; round < num_reps; round++) {
                sw.start;
                foreach (const ref qp; testingPoints) {
                    bucket.knnQuery(qp, k);
                }
                sw.stop;
                totalTime += sw.peek.total!"usecs";
            }
            long averageTime = totalTime/num_reps;
            file.writeln("kn,bucket,"~(to!string(k))~","~(to!string(n))~",2,U,"~(to!string(averageTime))~","~(to!string(i + 1)));
        }
    }

    //QuadTree Uniform and Gaussian Varying K and N
    for (int index = 0; index < k_values.length; index++) {
        int k = k_values[index];
        int N = N_values[index];
        string testType = "kn";
        string structType = "quadTree";
        testingQuadTree(file, testType, structType, k, N, trials, num_queries, "U");
        testingQuadTree(file, testType, structType, k, N, trials, num_queries, "G");
    }
    //Quadtree Uniform and Gaussin Varying N
    foreach (N; N_values) {
        int k = 10;
        string testType = "n";
        string structType = "quadTree";
        testingQuadTree(file, testType, structType, k, N, trials, num_queries, "U");
        testingQuadTree(file, testType, structType, k, N, trials, num_queries, "G");
    }
    //QuadTree Uniform and Gaussian Varying k
    foreach (k; k_values) {
        string testType = "k";
        string structType = "quadTree";
        int N = 1000;
        testingQuadTree(file, testType, structType, k, N, trials, num_queries, "U");
        testingQuadTree(file, testType, structType, k, N, trials, num_queries, "G");
    }
    //#-------------------------------------
    //KDTree Uniform and Gaussian Varying k
    foreach(k; k_values) {
        string testType = "k";
        string strucType = "kdTree";
        int N = 1000;
        static foreach(D; 2 .. 3) {{
            testingKDTree!D(file, testType, strucType, k, N, trials, num_queries, "U");
            testingKDTree!D(file, testType, strucType, k, N, trials, num_queries, "G");
        }}
    }
    //KDTree Uniform and Gaussian Varying N
    foreach(N; N_values) {
        string testType = "n";
        string structType = "kdTree";
        int k = 10;
        static foreach(D; 2 .. 3) {{
            testingKDTree!D(file, testType, structType, k, N, trials, num_queries, "U");
            testingKDTree!D(file, testType, structType, k, N, trials, num_queries, "G");
        }}
    }
    //KDTree Uniform and Gaussian Varying k and N
    for (int index = 0; index < k_values.length; index++) {
        int k = k_values[index];
        int N = N_values[index];
        string testType = "kn";
        string structType = "kdTree";
        static foreach (D; 2 .. 3) {{
            testingKDTree!D(file, testType, structType, k, N, trials, num_queries, "U");
            testingKDTree!D(file, testType, structType, k, N, trials, num_queries, "G");
        }}
    }
    //KDTree Gaussian Varying D
    static foreach (D; 1 .. 8) {{
        string testType = "d";
        string structType = "kdTree";
        int k = 10;
        int N = 1000;
        string distribution_type = "G";
    
        foreach (trial; 0 .. trials) {
            long totalTime = 0;
            Point!D[] trainingPoints = getGaussianPoints!D(N);
            Point!D[] testingPoints = getUniformPoints!D(num_queries);
            auto tree = KDTree!D(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for (int round = 0; round < 50; round++) {
                sw.start;
                foreach(const ref qp; testingPoints) {
                    tree.knnQuery(qp, k);
                }
                sw.stop;
                totalTime += sw.peek.total!"usecs";
            }
            long averageTime = totalTime / 50;
            file.writeln(testType, ",", structType, "," , k, ",", N, ",", D, ",", distribution_type, ",", averageTime, ",", trial + 1);
        }
    }}
    //KDTree Uniform Varying D
    static foreach (D; 1 .. 8) {{
        string testType = "d";
        string structType = "kdTree";
        int k = 10;
        int N = 1000;
        string distribution_type = "U";
    
        foreach (trial; 0 .. trials) {
            long totalTime = 0;
            Point!D[] trainingPoints = getUniformPoints!D(N);
            Point!D[] testingPoints = getUniformPoints!D(num_queries);
            auto tree = KDTree!D(trainingPoints);
            auto sw = StopWatch(AutoStart.no);
            for (int round = 0; round < 50; round++) {
                sw.start;
                foreach(const ref qp; testingPoints) {
                    tree.knnQuery(qp, k);
                }
                sw.stop;
                totalTime += sw.peek.total!"usecs";
            }
            long averageTime = totalTime / 50;
            file.writeln(testType, ",", structType, "," , k, ",", N, ",", D, ",", distribution_type, ",", averageTime, ",", trial + 1);
        }
    }}
    file.close();
}//end of main

// Template function for KDTree testing with compile-time dimension D
template testingKDTree(int D)
{
    void testingKDTree(File file, string testType, string structType, int k, int N, int trials, int num_queries, string distribution_type) {
        performTestingImpl!(D, KDTree)(file,testType, structType, k, N, trials, num_queries, distribution_type);
    }
}

// Function for QuadTree testing (always 2D)
void testingQuadTree(File file, string testType, string structType, int k, int N, int trials, int num_queries, string distribution_type) {
    performTestingImpl!(2, QuadTree)(file, testType, structType, k, N, trials, num_queries, distribution_type);
}

// Template for performing the actual testing
template performTestingImpl(int D, alias TreeType)
{
    void performTestingImpl(File file, string testType, string structType, int k, int N, int trials, int num_queries, string distribution_type) {
        foreach (trial; 0 .. trials) {
            // Generate points
            Point!D[] trainingPoints;
            Point!D[] testingPoints;
            //if distribution is Uniform
            //assigns training points and testing points based on distribution
            // and its test type
            if (distribution_type == "U") {
                if (testType == "k" || testType == "d") {
                    trainingPoints = getUniformPoints!D(N);
                    testingPoints = getUniformPoints!D(num_queries);
                } else { //else are n or kn test types
                    trainingPoints = getUniformPoints!D(N);
                    testingPoints = getUniformPoints!D(N/num_queries);
                }
                //else distribution type is Gaussian
            } else {
                if (testType == "k" || testType == "d") {
                    trainingPoints = getGaussianPoints!D(N);
                    testingPoints = getUniformPoints!D(num_queries);
                } else { //else are n or kn test types
                    trainingPoints = getGaussianPoints!D(N);
                    testingPoints = getUniformPoints!D(N/num_queries);
                }
            }
            //assigns which data structure tree will perform query
            if (structType == "quadTree") {
                QuadTree tree = QuadTree(trainingPoints);
                long totalTime = 0;
                auto sw = StopWatch(AutoStart.no);
                for (int round = 0; round < 50; round++) {
                    sw.start;
                    foreach(const ref qp; testingPoints) {
                        tree.knnQuery(qp, k);
                    }
                    sw.stop;
                    totalTime += sw.peek.total!"usecs";
                }
                long averageTime = totalTime / 50;
                file.writeln(testType, ",", structType, ",", k, ",", N, ",", D, ",", distribution_type, ",", averageTime, ",", trial + 1);
            }
            if (structType == "kdTree") {
                auto tree = KDTree!D(trainingPoints);
                long totalTime = 0;
                auto sw = StopWatch(AutoStart.no);
                for (int round = 0; round < 50; round++) {
                    sw.start;
                    foreach(const ref qp; testingPoints) {
                        tree.knnQuery(qp, k);
                    }
                    sw.stop;
                    totalTime += sw.peek.total!"usecs";
                }
                long averageTime = totalTime / 50;
                file.writeln(testType, ",", structType, ",", k, ",", N, ",", D, ",", distribution_type, ",", averageTime, ",", trial + 1);
            }
        }//end of each trial loop
    }//end of performTestingImpl method
}//end of template function
//Author: Brian Erichsen Fagundes
//CS6017 - Summer - 2014
// Implementation of a KdTree Data Structure

module kdtree;

import std.stdio;
import common;
import std.algorithm : partition;
import std.math;
import std.container : BinaryHeap;

alias P2 = Point!2;

struct KDTree {
    //takes specific dimention as param
    private class Node(size_t splitDimension) {
        //defines the next level's split dimension
        static if (splitDimension + 1 == 2) {
            enum nextLevel = 0;
        } else {
            enum nextLevel = splitDimension + 1;
        }
        // Fields to store point, child nodes, and aabb for this node
        Point!2 point; //median point for this node
        Node!nextLevel left;
        Node!nextLevel right;
        AABB!2 aabb;

        //constructor for Node class
        this(Point!2[] points, AABB!2 aabb) {
            writeln("Creating node with points: ", points);
            this.aabb = aabb;
            // Ensures points array is not empty
            if (points.length == 0) {
                writeln("Error: Trying to create a node with empty points array!");
                return;
            }
            //base case if list contains only 1 point
            if (points.length == 1) {
                point = points[0];
            }
            //find the median point along the split dimension
            //left half points
            auto leftPoints = points.medianByDimension!splitDimension;
            // '$' means length of array when slicing
            // uses the median for slicing
            //this.point = leftPoints[$ / 2];
            this.point = points[leftPoints.length];
            writeln("Selected median point: ", this.point);
            //partition points into left and right based on median
            auto rightPoints = points[points.length / 2 + 1 .. $];
            //leftPoints = points[0 .. $ / 2];
            //auto leftPoints = points[0 .. $ - rightPoints.length];
            writeln("Left points: ", leftPoints);
            writeln("Right points: ", rightPoints);

            // Creates left child node if there are points on left side
            if (leftPoints.length > 0) {
                auto leftAABB = aabb;
                leftAABB.max[splitDimension] = point[splitDimension];
                left = new Node!nextLevel(leftPoints, leftAABB);
            }
            // Creates right child node if there are points on the right side
            if (rightPoints.length > 0) {
                auto rightAABB = aabb;
                rightAABB.min[splitDimension] = point[splitDimension];
                right = new Node!nextLevel(rightPoints, rightAABB);
            }
        }
    }//end of Class node

    private Node!0 root;

    this(Point!2[] points) {
        writeln("Creating KDTree with points: ", points);
        auto aabb = boundingBox(points);
        writeln("Bounding box: ", aabb);
        root = new Node!0(points, aabb);
    }

    //finds all points within certain distance r from point p
    P2[] rangeQuery(P2 p, float r) {
        P2[] result;//empty array to store points
        //handles recursive traversal from point
        //template parameter that allows function to be called with nodes
        //of different split dimentions
        void recurse(NodeType)(NodeType node) {
            //consider point first
            //return early since no points are within desired distance
            if (distance(node.aabb.closest(p), p) >= r) return;
            //if its a leaf node, check the point stored in the node
            //if (node.left is null && node.right is null) {
                // stores result if within distance
            if (distance(p, node.point) <= r) result ~= node.point;
            //} else {
                //if its not a leaf node, recurse child nodes
            if (node.left !is null) recurse(node.left);
            if (node.right !is null) recurse(node.right);
            //}
        }//end of recurse method
        recurse(root);//recurse from root
        return result;//returns array of points within distance
    }//end of rangeQuery method

    //Finds the k nearest neighbots point to p
    Point!2[] knnQuery(Point!2 p, int k) {
        //initializes max-heap priority queue to store points prioritized
        // by distance to point p
        auto pq = makePriorityQueue!2(p);
        //traverse
        //template parameter that allows function to be called with nodes
        //of different split dimentions
        void recurse(NodeType)(NodeType node) {
            //if its leaf insert points into priority queue
            if (node.left is null && node.right is null) {
                pq.insert(node.point);
            } else {
                //internal node recurse each side
                if (node.left !is null) recurse(node.left);
                if (node.right !is null) recurse(node.right);
            }
        }//end of recurse
        recurse(root);//starts recursion from root
        //extract all points from PQ
        auto results = pq.release;
        results.topNByDistance(p, k);
        return results[0 .. k];
    }
}//end of struct KDTree

// combined range query and knn query in 1 unittest for simplification
unittest {
    Point!2[] points = [Point!2([0.5, 0.5]), Point!2([0.7, 0.7]), Point!2([0.2, 0.3]), Point!2([0.9, 0.9])];
    auto kd = KDTree(points);
    auto rqResults = kd.rangeQuery(Point!2([0.5, 0.5]), 0.3);
    writeln("KD Range Query Length: " ,rqResults.length);
    assert(rqResults.length == 2);

    auto knnResults = kd.knnQuery(Point!2([0.5, 0.5]), 2);
    writeln("KD KNNQuery Length: ", knnResults.length);
    assert(knnResults.length == 2);

    Point!2[] points2 =  [Point!2([0.1, 0.1]), Point!2([0.9, 0.9]), Point!2([0.3, 0.4]), Point!2([0.8, 0.2])];
    auto kd2 = KDTree(points2);
    auto rqResults2 = kd2.rangeQuery(Point!2([0.5, 0.5]), 0.4);
    assert(rqResults2.length == 1);

    auto knnResults2 = kd2.knnQuery(Point!2([0.5, 0.5]), 1);
    assert(knnResults2.length == 1);
}
//Author: Brian Erichsen Fagundes
//CS6017 - Summer - 2014
// Implementation of a KdTree Data Structure

module kdtree;

import common;
import std.algorithm : partition;
import std.math;
//import std.typecons : tuple;
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
            this.aabb = aabb;
            //find the median point along the split dimension
            auto median = points.medianByDimension!splitDimension;
            // '$' means length of array when slicing
            this.point = median[$ / 2];
            //partition points into left and right based on median
            auto rightPoints = points.partitionByDimension!splitDimension(point[splitDimension]);
            auto leftPoints = points[0 .. $ - rightPoints.length];

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
        auto aabb = boundingBox(points);
        root = new Node!0(points, aabb);
    }
    //finds all points within certain distance r from point p
    P2[] rangeQuery(P2 p, float r) {
        P2[] result;//empty array to store points
        //handles recursive traversal from point
        //template parameter that allows function to be called with nodes
        //of different split dimentions
        void recurse(NodeType)(NodeType node) {
            //return early since no points are within desired distance
            if (distance(node.aabb.closest(p), p) > r) return;
            //if its a leaf node, check the point stored in the node
            if (node.left is null && node.right is null) {
                // stores result if within distance
                if (distance(p, node.point) <= r) result ~= node.point;
            } else {
                //if its not a leaf node, recurse child nodes
                if (node.left !is null) recurse(node.left);
                if (node.right !is null) recurse(node.right);
            }
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
            //if its leaf insert points into queue
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

unittest {
    Point!2[] points = [Point!2([0.5, 0.5]), Point!2([0.7, 0.7]), Point!2([0.2, 0.3]), Point!2([0.9, 0.9])];
    auto kd = KDTree(points);
    auto rqResults = kd.rangeQuery(Point!2([0.5, 0.5]), 0.3);
    assert(rqResults.length == 2);

    auto knnResults = kd.knnQuery(Point!2([0.5, 0.5]), 2);
    assert(knnResults.length == 2);
}
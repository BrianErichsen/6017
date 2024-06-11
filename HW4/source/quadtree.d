//Author: Brian Erichsen Fagundes
//CS6017 - Summer - 2014
// Implementation of a QuadTree Data Structure

/* ! is template arguments - any type like T in c++*/


module quadtree;
import common;
import std.algorithm : partition;
import std.math;

alias P2 = Point!2;

struct QuadTree {
    private class Node {
        P2[] points;//list of points
        Node[4] children;//4 children
        AABB!2 aabb;//bounding box
        bool isLeaf;

        //constructor
        this(P2[] points, AABB!2 aabb, int capacity = 4) {
            this.points = points;
            this.aabb = aabb;
            // leaf if actual points does not have any children
            this.isLeaf = points.length <= capacity;
            //if not leaf -- then partition points into 4 quadrants
            if (!isLeaf) {
                AABB!2[] subAABBs = splitAABB(aabb);//divides into 4
                //array holding points of each of 4 quadrants
                P2[][] subPoints = new P2[][4];
                //distributes points into sub-points array
                foreach (p; points) {
                    foreach (i; 0 .. 4) {
                        //checks if sub aabb belongs to inAABB
                        if (inAABB(subAABBs[i], p)) {
                            //apprends point to array
                            subPoints[i] ~= p;
                            break;
                        }
                    }
                }
                //create child nodes for each 4 quadrants
                foreach (i; 0 .. 4) {
                    //if there are points in the subPoints
                    if (subPoints[i].length > 0) {
                        //creates new child
                        children[i] = new Node(subPoints[i], subAABBs[i]);
                    }
                }
            }
        }//end of constructor method
        // split current bounding box into 4 smaller bounding boxes
        AABB!2[] splitAABB(AABB!2 aabb) {
            auto mid = (aabb.min + aabb.max) / 2;
            return [
                AABB!2(aabb.min, mid), //bottom-left quadrant
                //top left quadrant
                AABB!2(Point!2([aabb.min[0], mid[1]]), Point!2([mid[0], aabb.max[1]])),
                AABB!2(mid, aabb.max), //top right quadrant
                //bottom right quadrant
                AABB!2(Point!2([mid[0], aabb.min[1]]), Point!2([aabb.max[0], mid[1]]))
            ];
        }
        // checks if given point is within bounding box
        bool inAABB(AABB!2 aabb, P2 p) {
            return p[0] >= aabb.min[0] && p[0] <= aabb.max[0] &&
            p[1] >= aabb.min[1] && p[1] <= aabb.max[1];
        }
    } //end of class Node
    private Node root;
    //constructor for QuadTree
    this(P2[] points) {
        auto aabb = boundingBox(points);
        root = new Node(points, aabb);
    }//end of struct constructror

//finds all points within certain distance r from point p
    P2[] rangeQuery(P2 p, float r) {
        P2[] result;//creates empty array to store points
        //handles recursive traversal of quadtree
        void recurse(Node node) {
            //if closest point in nodes aabb is further then
            //return early since no points are within desired distance
            if (distance(node.aabb.closest(p), p) > r) return;
            //if it is leaf; then iterate over its points
            if (node.isLeaf) {
                foreach (q; node.points) {
                    if (distance(p, q) <= r) {
                        //if distance is within distance then add to result
                        result ~=q;
                    }
                }
                //else it is a internal node recursive traverse each non null node
            } else {
                foreach (child; node.children) {
                    if (child !is null) {
                        recurse(child);
                    }
                }
            }
        }
        recurse(root);//starts recursion from root
        return result;// returns the array of points within r to p
    }//end of range-query function

    //finds the k nearest neighbors to point p
    P2[] knnQuery(P2 p, int k) {
        //initializes max-heap priority queue to store points prioritized
        // by distance to point p
        auto pq = makePriorityQueue!2(p);
        //traverse quadtree
        void recurse(Node node) {
            //if its leaf then insert all points into priority queue
            if (node.isLeaf) {
                foreach (q; node.points) pq.insert(q);
            } else { //if its internal node
                //recurse each child that is not null
                foreach (child; node.children) {
                    if (child !is null) recurse(child);
                }
            }
        }
        recurse(root); //starts recursion
        //extracts all points from priority queue and sorts them by distance to p
        auto results = pq.release;
        results.topNByDistance(p, k);
        return results[0 .. k];//returns k closest points to p
    }
} //end of QuadTree struct

unittest
{
    P2[] points = [P2([0.5, 0.5]), P2([0.7, 0.7]), P2([0.2, 0.3]), P2([0.9, 0.9])];
    auto qt = QuadTree(points);
    auto rqResults = qt.rangeQuery(P2([0.5, 0.5]), 0.3);
    assert(rqResults.length == 2);

    auto knnResults = qt.knnQuery(P2([0.5, 0.5]), 2);
    assert(knnResults.length == 2);
}

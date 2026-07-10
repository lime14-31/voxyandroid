#import <voxy:lod/pos_util.glsl>
layout(binding = NODE_DATA_BINDING, std430) restrict buffer NodeData {
//Needs to be read and writeable for marking data,
//(could do an evil violation, make this readonly, then have a writeonly varient, which means that writing might not be visible but will show up by the next frame)
//Nodes are 16 bytes big (or 32 cant decide, 16 might _just_ be enough)
    uvec4[] nodes;
};

//First 2 are joined to be the position

//All node access and setup into global variables
//TODO: maybe make it global vars
struct UnpackedNode {
    uint nodeId;

    uvec2 rawPos;

    ivec3 pos;
    uint lodLevel;

    uint flags;

    uint meshPtr;
    uint childPtr;
};

#define NULL_NODE ((1u << 24u) - 1u)
#define EMPTY_QUEUE_ID ((1u << 24u) - 2u)
#define NULL_MESH ((1u << 24u) - 1u)
#define EMPTY_MESH ((1u << 24u) - 2u)

uvec4 unpackNode(out UnpackedNode node, uint nodeId) {
    uvec4 compactedNode = nodes[nodeId];
    node.nodeId = nodeId;
    node.lodLevel = getLoDLevel(compactedNode.xy);
    node.rawPos = compactedNode.xy;
    node.pos = getLoDPosition(compactedNode.xy);

    node.meshPtr = compactedNode.z&0xFFFFFFu;
    node.childPtr = compactedNode.w&0xFFFFFFu;
    node.flags = ((compactedNode.z >> 24u) & 0xFFu) |
             (((compactedNode.w >> 24u) & 0xFFu) << 8u);
    return compactedNode;
}

bool hasMesh(in UnpackedNode node) {
    return node.meshPtr != NULL_MESH;
}

bool isEmptyMesh(in UnpackedNode node) {
    return node.meshPtr == EMPTY_MESH;//Specialcase
}

bool hasChildren(in UnpackedNode node) {
    return node.childPtr != NULL_NODE;
}

bool childListIsEmpty(in UnpackedNode node) {
    return node.childPtr == EMPTY_QUEUE_ID;
}

//bool isEmpty(in UnpackedNode node) {
//    return (node.flags&2u) != 0;
//}

bool hasRequested(in UnpackedNode node) {
    return (node.flags&1u) != 0u;
}

uint getMesh(in UnpackedNode node) {
    return node.meshPtr;
}

uint getId(in UnpackedNode node) {
    return node.nodeId;
}

uint getChildCount(in UnpackedNode node) {
    return ((node.flags >> 2u) & 7u) + 1u;
}

uint getChildPtr(in UnpackedNode node) {
    return node.childPtr;
}

uvec2 getRawPos(in UnpackedNode node) {
    return node.rawPos;
}

/*
uint getTransformIndex(in UnpackedNode node) {
    return (node.flags >> 5u) & 31u;
}*/

//-----------------------------------

void markRequested(inout UnpackedNode node) {
    node.flags |= 1u;
    nodes[node.nodeId].z |= 1u << 24u;
}

void debugDumpNode(in UnpackedNode node) {
}
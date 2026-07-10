#ifndef _POS_UTIL_DECL
#define _POS_UTIL_DECL

uint getLoDLevel(uvec2 packedPos) {
    return packedPos.x >> 28u;
}

ivec3 getLoDPosition(uvec2 packedPos) {
    int y = ((int(packedPos.x) << 4) >> 24);
int x = (int(packedPos.y) << 4) >> 8;
int z = int((packedPos.x & ((1u << 20u) - 1u)) << 4);
z |= int(packedPos.y >> 28u);
    z <<= 8;
    z >>= 8;
    return ivec3(x,y,z);
}

#endif
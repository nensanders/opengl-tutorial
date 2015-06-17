/*
 * Copyright (c) 2011-2015, 2time.net | Sven Otto
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package tests.directionalLightTest;

import gl.GLDefines;
import types.DataType;
import gl.GL;
import types.Data;
import tests.utils.IMesh;

class CubeMesh implements IMesh
{
    inline static private var sizeOfFloat: Int = 4;
    inline static private var sizeOfShort: Int = 2;

    inline static private var positionAttributeCount: Int = 4;
    inline static private var colorAttributeCount: Int = 4;
    inline static private var normalAttributeCount: Int = 3;

    inline static private var positionAttributeIndex: Int = 0;
    inline static private var colorAttributeIndex: Int = 1;
    inline static private var normalAttributeIndex: Int = 2;

    private var indexCount: Int;

    private var vertexBufferData: Data;

    private var vertexBuffer: GLBuffer;
    private var indexBuffer: GLBuffer;

    public function new ()
    {
    }

    public function createBuffers(): Void
    {
        //                                         x     y     z    w    r    g    b    a     nx    ny    nz
        var vertexBufferValues: Array<Float> = [ -0.5, -0.5,  0.5, 1.0, 0.0, 0.0, 1.0, 1.0,  0.0,  0.0,  1.0, //Front
                                                 -0.5,  0.5,  0.5, 1.0, 0.0, 0.0, 1.0, 1.0,  0.0,  0.0,  1.0,
                                                  0.5,  0.5,  0.5, 1.0, 0.0, 0.0, 1.0, 1.0,  0.0,  0.0,  1.0,
                                                  0.5, -0.5,  0.5, 1.0, 0.0, 0.0, 1.0, 1.0,  0.0,  0.0,  1.0,

                                                 -0.5, -0.5, -0.5, 1.0, 0.0, 0.0, 1.0, 1.0,  0.0,  0.0, -1.0, //Back
                                                 -0.5,  0.5, -0.5, 1.0, 0.0, 0.0, 1.0, 1.0,  0.0,  0.0, -1.0,
                                                  0.5,  0.5, -0.5, 1.0, 0.0, 0.0, 1.0, 1.0,  0.0,  0.0, -1.0,
                                                  0.5, -0.5, -0.5, 1.0, 0.0, 0.0, 1.0, 1.0,  0.0,  0.0, -1.0,

                                                 -0.5,  0.5,  0.5, 1.0, 0.0, 1.0, 0.0, 1.0,  0.0,  1.0,  0.0, //Top
                                                 -0.5,  0.5, -0.5, 1.0, 0.0, 1.0, 0.0, 1.0,  0.0,  1.0,  0.0,
                                                  0.5,  0.5, -0.5, 1.0, 0.0, 1.0, 0.0, 1.0,  0.0,  1.0,  0.0,
                                                  0.5,  0.5,  0.5, 1.0, 0.0, 1.0, 0.0, 1.0,  0.0,  1.0,  0.0,

                                                 -0.5, -0.5,  0.5, 1.0, 0.0, 1.0, 0.0, 1.0,  0.0, -1.0,  0.0, //Bottom
                                                 -0.5, -0.5, -0.5, 1.0, 0.0, 1.0, 0.0, 1.0,  0.0, -1.0,  0.0,
                                                  0.5, -0.5, -0.5, 1.0, 0.0, 1.0, 0.0, 1.0,  0.0, -1.0,  0.0,
                                                  0.5, -0.5,  0.5, 1.0, 0.0, 1.0, 0.0, 1.0,  0.0, -1.0,  0.0,

                                                 -0.5, -0.5, -0.5, 1.0, 1.0, 0.0, 0.0, 1.0, -1.0,  0.0,  0.0, //Left
                                                 -0.5,  0.5, -0.5, 1.0, 1.0, 0.0, 0.0, 1.0, -1.0,  0.0,  0.0,
                                                 -0.5,  0.5,  0.5, 1.0, 1.0, 0.0, 0.0, 1.0, -1.0,  0.0,  0.0,
                                                 -0.5, -0.5,  0.5, 1.0, 1.0, 0.0, 0.0, 1.0, -1.0,  0.0,  0.0,

                                                  0.5, -0.5, -0.5, 1.0, 1.0, 0.0, 0.0, 1.0,  1.0,  0.0,  0.0, //Right
                                                  0.5,  0.5, -0.5, 1.0, 1.0, 0.0, 0.0, 1.0,  1.0,  0.0,  0.0,
                                                  0.5,  0.5,  0.5, 1.0, 1.0, 0.0, 0.0, 1.0,  1.0,  0.0,  0.0,
                                                  0.5, -0.5,  0.5, 1.0, 1.0, 0.0, 0.0, 1.0,  1.0,  0.0,  0.0 ];

        vertexBufferData = new Data(vertexBufferValues.length * sizeOfFloat);
        vertexBufferData.writeFloatArray(vertexBufferValues, DataType.DataTypeFloat32);
        vertexBufferData.offset = 0;

        vertexBuffer = GL.createBuffer();
        GL.bindBuffer(GLDefines.ARRAY_BUFFER, vertexBuffer);
        GL.bufferData(GLDefines.ARRAY_BUFFER, vertexBufferData, GLDefines.DYNAMIC_DRAW);
        GL.bindBuffer(GLDefines.ARRAY_BUFFER, GL.nullBuffer);


        var indexBufferValues: Array<Int> = [ 0,  1,  2,  0,  2,  3,  7,  6,  5,  7,  5,  4,    // Z-Axis
                                              8,  9, 10,  8, 10, 11, 15, 14, 13, 15, 13, 12,    // Y-Axis
                                             16, 17, 18, 16, 18, 19, 23, 22, 21, 23, 21, 20 ];  // X-Axis

        indexCount = indexBufferValues.length;
        var indexBufferData: Data = new Data(indexCount * sizeOfShort);
        indexBufferData.writeIntArray(indexBufferValues, DataType.DataTypeUInt16);
        indexBufferData.offset = 0;

        indexBuffer = GL.createBuffer();
        GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, indexBuffer);
        GL.bufferData(GLDefines.ELEMENT_ARRAY_BUFFER, indexBufferData, GLDefines.STATIC_DRAW);
        GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, GL.nullBuffer);
    }

    public function destroyBuffers(): Void
    {
        GL.deleteBuffer(indexBuffer);
        GL.deleteBuffer(vertexBuffer);
    }

    public function bindMesh(): Void
    {
        GL.bindBuffer(GLDefines.ARRAY_BUFFER, vertexBuffer);
        GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, indexBuffer);

        GL.enableVertexAttribArray(positionAttributeIndex); // 0
        GL.enableVertexAttribArray(colorAttributeIndex);    // 1
        GL.enableVertexAttribArray(normalAttributeIndex);   // 2

        GL.disableVertexAttribArray(3);
        GL.disableVertexAttribArray(4);
        GL.disableVertexAttribArray(5);
        GL.disableVertexAttribArray(6);
        GL.disableVertexAttribArray(7);

        var stride: Int = positionAttributeCount * sizeOfFloat + colorAttributeCount * sizeOfFloat + normalAttributeCount * sizeOfFloat;

        var attributeOffset: Int = 0;
        GL.vertexAttribPointer(positionAttributeIndex, positionAttributeCount, GLDefines.FLOAT, false, stride, attributeOffset);

        attributeOffset = positionAttributeCount * sizeOfFloat;
        GL.vertexAttribPointer(colorAttributeIndex, colorAttributeCount, GLDefines.FLOAT, false, stride, attributeOffset);

        attributeOffset = positionAttributeCount * sizeOfFloat + colorAttributeCount * sizeOfFloat;
        GL.vertexAttribPointer(normalAttributeIndex, normalAttributeCount, GLDefines.FLOAT, false, stride, attributeOffset);
    }

    public function unbindMesh(): Void
    {
        GL.bindBuffer(GLDefines.ARRAY_BUFFER, GL.nullBuffer);
        GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, GL.nullBuffer);
    }

    public function draw(): Void
    {
        var indexOffset: Int = 0;
        GL.drawElements(GLDefines.TRIANGLES, indexCount, GLDefines.UNSIGNED_SHORT, indexOffset);
    }
}

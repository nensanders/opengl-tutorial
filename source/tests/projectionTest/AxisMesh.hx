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

package tests.projectionTest;

import gl.GLDefines;
import gl.GL;
import types.Data;
import types.DataType;
import tests.utils.IMesh;

class AxisMesh implements IMesh
{
    inline static private var sizeOfFloat: Int = 4;
    inline static private var sizeOfShort: Int = 2;

    inline static private var positionAttributeCount: Int = 4;
    inline static private var colorAttributeCount: Int = 4;

    inline static private var positionAttributeIndex: Int = 0;
    inline static private var colorAttributeIndex: Int = 1;

    inline static private var indexCount: Int = 72;

    private var vertexBufferData: Data;

    private var vertexBuffer: GLBuffer;
    private var indexBuffer: GLBuffer;

    public function new ()
    {
    }

    public function createBuffers(): Void
    {
        /// VertexBuffer also called Array Buffer

        var vertexCount: Int = 23;
        var vertexBufferSize: Int = vertexCount * (sizeOfFloat * positionAttributeCount + sizeOfFloat * colorAttributeCount);
        vertexBufferData = new Data(vertexBufferSize);
        //                                       x     y     z    w    r    g    b    a
        var vertexBufferValues: Array<Float> = [ 1.0,  0.0,  0.0, 1.0, 1.0, 0.5, 0.0, 1.0,    // vertex 0  ---> X-Axis
                                                 0.1,  0.1,  0.1, 1.0, 1.0, 0.0, 0.0, 1.0,    // vertex 1
                                                 0.1,  0.1, -0.1, 1.0, 1.0, 0.0, 0.0, 1.0,    // vertex 2
                                                 0.1, -0.1, -0.1, 1.0, 1.0, 0.0, 0.0, 1.0,    // vertex 3
                                                 0.1, -0.1,  0.1, 1.0, 1.0, 0.0, 0.0, 1.0,    // vertex 4
                                                 0.0,  1.0,  0.0, 1.0, 1.0, 1.0, 0.0, 1.0,    // vertex 5  ---> Y-Axis
                                                 0.1,  0.1,  0.1, 1.0, 0.0, 1.0, 0.0, 1.0,    // vertex 6
                                                -0.1,  0.1,  0.1, 1.0, 0.0, 1.0, 0.0, 1.0,    // vertex 7
                                                -0.1,  0.1, -0.1, 1.0, 0.0, 1.0, 0.0, 1.0,    // vertex 8
                                                 0.1,  0.1, -0.1, 1.0, 0.0, 1.0, 0.0, 1.0,    // vertex 9
                                                 0.0,  0.0,  1.0, 1.0, 0.0, 0.5, 1.0, 1.0,    // vertex 10 ---> Z-Axis
                                                 0.1,  0.1,  0.1, 1.0, 0.0, 0.0, 1.0, 1.0,    // vertex 11
                                                 0.1, -0.1,  0.1, 1.0, 0.0, 0.0, 1.0, 1.0,    // vertex 12
                                                -0.1, -0.1,  0.1, 1.0, 0.0, 0.0, 1.0, 1.0,    // vertex 13
                                                -0.1,  0.1,  0.1, 1.0, 0.0, 0.0, 1.0, 1.0,    // vertex 14
                                                 0.1,  0.1,  0.1, 1.0, 1.0, 1.0, 1.0, 1.0,    // vertex 15 ---> Cube
                                                -0.1,  0.1,  0.1, 1.0, 1.0, 1.0, 1.0, 1.0,    // vertex 16
                                                -0.1,  0.1, -0.1, 1.0, 1.0, 1.0, 1.0, 1.0,    // vertex 17
                                                 0.1,  0.1, -0.1, 1.0, 1.0, 1.0, 1.0, 1.0,    // vertex 18
                                                 0.1, -0.1,  0.1, 1.0, 1.0, 1.0, 1.0, 1.0,    // vertex 19
                                                -0.1, -0.1,  0.1, 1.0, 1.0, 1.0, 1.0, 1.0,    // vertex 20
                                                -0.1, -0.1, -0.1, 1.0, 1.0, 1.0, 1.0, 1.0,    // vertex 21
                                                 0.1, -0.1, -0.1, 1.0, 1.0, 1.0, 1.0, 1.0];   // vertex 22

        vertexBufferData.writeFloatArray(vertexBufferValues, DataType.DataTypeFloat32);
        vertexBufferData.offset = 0;

        vertexBuffer = GL.createBuffer();
        GL.bindBuffer(GLDefines.ARRAY_BUFFER, vertexBuffer);
        GL.bufferData(GLDefines.ARRAY_BUFFER, vertexBufferData, GLDefines.DYNAMIC_DRAW);
        GL.bindBuffer(GLDefines.ARRAY_BUFFER, GL.nullBuffer);


        /// IndexBuffer also called Element (Array) Buffer

        var indexBufferSize: Int = indexCount * sizeOfShort;
        var indexBufferData: Data = new Data(indexBufferSize);

        var indexBufferValues: Array<Int> = [ 0,  4,  1,  0,  1,  2,  0,  2,  3,  0,  3,  4,    // X-Axis
                                              5,  9,  6,  5,  6,  7,  5,  7,  8,  5,  8,  9,    // Y-Axis
                                             10, 14, 11, 10, 11, 12, 10, 12, 13, 10, 13, 14,    // Z-Axis
                                             15, 16, 17, 15, 17, 18, 19, 21, 20, 19, 22, 21,    // Cube (Y)
                                             15, 18, 22, 15, 22, 19, 16, 21, 17, 16, 20, 21,    // Cube (X)
                                             15, 19, 20, 15, 20, 16, 18, 17, 21, 18, 21, 22];   // Cube (Z)


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

        GL.disableVertexAttribArray(2);
        GL.disableVertexAttribArray(3);
        GL.disableVertexAttribArray(4);
        GL.disableVertexAttribArray(5);
        GL.disableVertexAttribArray(6);
        GL.disableVertexAttribArray(7);

        var stride: Int = positionAttributeCount * sizeOfFloat + colorAttributeCount * sizeOfFloat;

        var attributeOffset: Int = 0;
        GL.vertexAttribPointer(positionAttributeIndex, positionAttributeCount, GLDefines.FLOAT, false, stride, attributeOffset);

        attributeOffset = positionAttributeCount * sizeOfFloat;
        GL.vertexAttribPointer(colorAttributeIndex, colorAttributeCount, GLDefines.FLOAT, false, stride, attributeOffset);
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

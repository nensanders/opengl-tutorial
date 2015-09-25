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

package tests.triangleTest;

import duellkit.DuellKit;
import types.Data;
import types.DataType;
import gl.GL;
import gl.GLDefines;

class TriangleTest extends OpenGLTest
{
    inline static private var sizeOfFloat: Int = 4;
    inline static private var sizeOfShort: Int = 2;

    inline static private var positionAttributeCount: Int = 4;
    inline static private var colorAttributeCount: Int = 4;

    inline static private var positionAttributeIndex: Int = 0;
    inline static private var colorAttributeIndex: Int = 1;

    inline static private var indexCount: Int = 3;

    inline static private var vertexShader =
        "
            attribute highp   vec4  a_Position;
            attribute lowp    vec4  a_Color;

            uniform highp     float u_Tint;

            varying lowp      vec4  v_Color;

            void main()
            {
                gl_Position = a_Position;
                v_Color = a_Color * u_Tint;
            }
        ";

    inline static private var fragmentShader =
        "
            varying lowp      vec4  v_Color;

            void main()
            {
                gl_FragColor = v_Color;
            }
        ";

    private var shaderProgram: GLProgram;
    private var vertexBuffer: GLBuffer;
    private var indexBuffer: GLBuffer;
    private var uniformLocation: GLUniformLocation;

    // Create OpenGL objectes (Shaders, Buffers, Textures) here
    override private function onCreate(): Void
    {
        super.onCreate();

        configureOpenGLState();
        createShader();
        createBuffers();
    }

    // Destroy your created OpenGL objectes
    override public function onDestroy(): Void
    {
        destroyBuffers();
        destroyShader();

        super.onDestroy();
    }

    private function configureOpenGLState(): Void
    {
        GL.clearColor(0.0, 0.4, 0.6, 1.0);
    }

    private function createShader()
    {
        /// COMPILE

        var vs = compileShader(GLDefines.VERTEX_SHADER, vertexShader);

        if(vs == GL.nullShader)
        {
            trace("Failed to compile vertex shader");
            return;
        }

        var fs = compileShader(GLDefines.FRAGMENT_SHADER, fragmentShader);

        if(fs == GL.nullShader)
        {
            trace("Failed to compile fragment shader");
            return;
        }

        /// CREATE

        shaderProgram = GL.createProgram();
        GL.attachShader(shaderProgram, vs);
        GL.attachShader(shaderProgram, fs);

        /// BIND ATTRIBUTE LOCATIONS

        GL.bindAttribLocation(shaderProgram, positionAttributeIndex, "a_Position");
        GL.bindAttribLocation(shaderProgram, colorAttributeIndex, "a_Color");

        /// LINK

        if(!linkShader(shaderProgram))
        {
            trace("Failed to link program");

            if(vs != GL.nullShader)
            {
                GL.deleteShader(vs);
            }
            if(fs != GL.nullShader)
            {
                GL.deleteShader(fs);
            }

            GL.deleteProgram(shaderProgram);
            return;
        }

        /// BIND UNIFORM LOCATIONS

        uniformLocation = GL.getUniformLocation(shaderProgram, "u_Tint");

        if(uniformLocation == GL.nullUniformLocation)
        {
            trace("Failed to link uniform " + "u_Tint" + " in shader");
        }

        /// CLEANUP

        if(vs != GL.nullShader)
        {
            GL.detachShader(shaderProgram, vs);
            GL.deleteShader(vs);
        }
        if(fs != GL.nullShader)
        {
            GL.detachShader(shaderProgram, fs);
            GL.deleteShader(fs);
        }
    }

    private function compileShader(type: Int, code: String): GLShader
    {
        var s = GL.createShader(type);
        GL.shaderSource(s, code);
        GL.compileShader(s);

        #if debug
        var log = GL.getShaderInfoLog(s);
        if(log.length > 0)
        {
            trace("Shader log:");
            trace(log);
        }
        #end

        if(GL.getShaderParameter(s, GLDefines.COMPILE_STATUS) != cast 1 )
        {
            GL.deleteShader(s);
            return GL.nullShader;
        }
        return s;
    }

    private function linkShader(shaderProgramName: GLProgram): Bool
    {
        GL.linkProgram(shaderProgramName);

        #if debug
        var log = GL.getProgramInfoLog(shaderProgramName);
        if(log.length > 0)
        {
            trace("Shader program log:");
            trace(log);
        }
        #end

        if(GL.getProgramParameter(shaderProgramName, GLDefines.LINK_STATUS) == 0)
            return false;
        return true;
    }

    private function destroyShader(): Void
    {
        GL.deleteProgram(shaderProgram);
    }

    private function createBuffers()
    {
        /// VertexBuffer also called Array Buffer

        var vertexCount: Int = 3;
        var vertexBufferSize: Int = vertexCount * (sizeOfFloat * positionAttributeCount + sizeOfFloat * colorAttributeCount);
        var vertexBufferData: Data = new Data(vertexBufferSize);
                                            //  x    y    z    w    r    g    b    a
        var vertexBufferValues: Array<Float> = [0.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0,     // vertex 0
                                                0.5, 0.5, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0,     // vertex 1
                                                0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0];    // vertex 2

        vertexBufferData.writeFloatArray(vertexBufferValues, DataType.DataTypeFloat32);
        vertexBufferData.offset = 0;

        vertexBuffer = GL.createBuffer();
        GL.bindBuffer(GLDefines.ARRAY_BUFFER, vertexBuffer);
        GL.bufferData(GLDefines.ARRAY_BUFFER, vertexBufferData, GLDefines.STATIC_DRAW);
        GL.bindBuffer(GLDefines.ARRAY_BUFFER, GL.nullBuffer);


        /// IndexBuffer also called Element (Array) Buffer

        var indexBufferSize: Int = indexCount * sizeOfShort;
        var indexBufferData: Data = new Data(indexBufferSize);

        var indexBufferValues: Array<Int> = [0, 1, 2];  // These indices reference the vertices above.

        indexBufferData.writeIntArray(indexBufferValues, DataType.DataTypeUInt16);
        indexBufferData.offset = 0;

        indexBuffer = GL.createBuffer();
        GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, indexBuffer);
        GL.bufferData(GLDefines.ELEMENT_ARRAY_BUFFER, indexBufferData, GLDefines.STATIC_DRAW);
        GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, GL.nullBuffer);
    }

    private function destroyBuffers(): Void
    {
        GL.deleteBuffer(indexBuffer);
        GL.deleteBuffer(vertexBuffer);
    }

    override private function render()
    {
        var currentTime = DuellKit.instance().time;
        var tween = (Math.sin(currentTime) + 1.0) / 2.0;

        GL.clear(GLDefines.COLOR_BUFFER_BIT);

        GL.useProgram(shaderProgram);

        var tint: Float = 0.1 + 0.9 * tween;
        GL.uniform1f(uniformLocation, tint);

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

        var indexOffset: Int = 0;
        GL.drawElements(GLDefines.TRIANGLES, indexCount, GLDefines.UNSIGNED_SHORT, indexOffset);

        GL.bindBuffer(GLDefines.ARRAY_BUFFER, GL.nullBuffer);
        GL.bindBuffer(GLDefines.ELEMENT_ARRAY_BUFFER, GL.nullBuffer);
        GL.useProgram(GL.nullProgram);
    }
}

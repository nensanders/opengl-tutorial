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

import duell.DuellKit;
import gl.GL;
import gl.GLDefines;
import tests.projectionTest.AxisMesh;
import tests.utils.AssetLoader;
import tests.utils.Shader;
import types.Matrix4Tools;
import types.DataType;
import types.Vector3;
import types.Matrix4;

using types.Matrix4Tools;

class ProjectionTest extends OpenGLTest
{
    inline private static var VERTEXSHADER_PATH = "common/shaders/ScreenSpace_PosMVP.vsh";
    inline private static var FRAGMENTSHADER_PATH = "common/shaders/ScreenSpace_Color.fsh";

    private var textureShader: Shader;

    private var axisMesh: AxisMesh;

    private var moveVector: Vector3;

    private var workMatrix: Matrix4;

    private var perspectiveMatrix: Matrix4;
    private var orthogonalMatrix: Matrix4;

    private var modelMatrix: Matrix4;
    private var projectionMatrix: Matrix4;

    // Create OpenGL objectes (Shaders, Buffers, Textures) here
    override private function onCreate(): Void
    {
        super.onCreate();

        configureOpenGLState();
        createShader();
        createMesh();
    }

    // Destroy your created OpenGL objectes
    override public function onDestroy(): Void
    {
        destroyMesh();
        destroyShader();

        super.onDestroy();
    }

    private function configureOpenGLState(): Void
    {
        gl.GL.clearColor(0.0, 0.4, 0.6, 1.0);
        gl.GL.enable(GLDefines.DEPTH_TEST);
        gl.GL.depthMask(true);

        moveVector = new Vector3();
        moveVector.setXYZ(0.0, -0.5, -3.4);

        workMatrix = new Matrix4();

        var aspect: Float = DuellKit.instance().screenWidth / DuellKit.instance().screenHeight;

        perspectiveMatrix = new Matrix4();
        perspectiveMatrix.setPerspectiveFov(Math.PI / 5.41, aspect, 0.1, 2000.0);

        orthogonalMatrix = new Matrix4();
        orthogonalMatrix.setOrtho(-1.0, 1.0, -1.0, 1.0, 0.1, 2000.0);

        modelMatrix = new Matrix4();
        modelMatrix.setIdentity();
        modelMatrix.rotate(0.0, Math.PI * 0.1, 0.0);

        workMatrix.setIdentity();
        workMatrix.translate(moveVector.x, moveVector.y, moveVector.z);

        modelMatrix.multiply(workMatrix);

        projectionMatrix = new Matrix4();
    }

    private function createShader()
    {
        var vertexShader: String = AssetLoader.getStringFromFile(VERTEXSHADER_PATH);
        var fragmentShader: String = AssetLoader.getStringFromFile(FRAGMENTSHADER_PATH);

        textureShader = new Shader();
        textureShader.createShader(vertexShader, fragmentShader, ["a_Position", "a_Color"], ["u_Matrix"]);
    }

    private function destroyShader(): Void
    {
        textureShader.destroyShader();
    }

    private function createMesh()
    {
        axisMesh = new AxisMesh();
        axisMesh.createBuffers();
    }

    private function destroyMesh()
    {
        axisMesh.destroyBuffers();
    }

    private function update(deltaTime: Float, currentTime: Float)
    {
        var percent: Float = Math.sin(currentTime);

        if (percent >= 0)
        {
            //projectionMatrix.interpolate(perspectiveMatrix, orthogonalMatrix, 1 + percent); // interpolate
            projectionMatrix.set(orthogonalMatrix);                                           // set immediately

        }
        else
        {
            //projectionMatrix.interpolate(orthogonalMatrix, perspectiveMatrix, percent);
            projectionMatrix.set(perspectiveMatrix);
        }

        workMatrix.set(modelMatrix);
        workMatrix.multiply(projectionMatrix);

    }

    override private function render()
    {
        update(DuellKit.instance().frameDelta, DuellKit.instance().time);

        GL.clear(GLDefines.COLOR_BUFFER_BIT | GLDefines.DEPTH_BUFFER_BIT);

        GL.useProgram(textureShader.shaderProgram);

        gl.GL.uniformMatrix4fv(textureShader.uniformLocations[0], 1, false, workMatrix.data);

        axisMesh.bindMesh();

        axisMesh.draw();

        axisMesh.unbindMesh();

        GL.bindTexture(GLDefines.TEXTURE_2D, GL.nullTexture);

        GL.useProgram(GL.nullProgram);
    }
}
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

package tests.transformTest;

import duellkit.DuellKit;
import gl.GL;
import gl.GLDefines;
import tests.projectionTest.AxisMesh;
import tests.transformTest.PlaneMesh;
import tests.utils.AssetLoader;
import tests.utils.Shader;
import types.DataType;
import types.Matrix4;
import types.Matrix4Tools;
import types.Vector3;

using types.Matrix4Tools;

class TransformTest extends OpenGLTest
{
    inline private static var VERTEXSHADER_PATH = "common/shaders/Base_PosColor.vsh";
    inline private static var FRAGMENTSHADER_PATH = "common/shaders/Base_Color.fsh";

    private var textureShader: Shader;

    private var planeMesh: PlaneMesh;
    private var axisMesh: AxisMesh;

    private var moveVector: Vector3;

    private var workMatrix: Matrix4;

    private var modelMatrix: Matrix4;
    private var viewMatrix: Matrix4;
    private var projection: Matrix4;

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
        GL.clearColor(0.0, 0.4, 0.6, 1.0);
        GL.enable(GLDefines.DEPTH_TEST);
        GL.depthMask(true);

        moveVector = new Vector3();

        workMatrix = new Matrix4();

        modelMatrix = new Matrix4();
        modelMatrix.setIdentity();

        viewMatrix = new Matrix4();
        viewMatrix.setIdentity();

        var aspect: Float = DuellKit.instance().screenWidth / DuellKit.instance().screenHeight;

        projection = new Matrix4();
        projection.setPerspectiveFov(Math.PI * 0.3, aspect, 0.1, 2000.0);
    }

    private function createShader()
    {
        var vertexShader: String = AssetLoader.getStringFromFile(VERTEXSHADER_PATH);
        var fragmentShader: String = AssetLoader.getStringFromFile(FRAGMENTSHADER_PATH);

        textureShader = new Shader();
        textureShader.createShader(vertexShader, fragmentShader, ["a_Position", "a_Color"], ["u_MVPMatrix"]);
    }

    private function destroyShader(): Void
    {
        textureShader.destroyShader();
    }

    private function createMesh()
    {
        axisMesh = new AxisMesh();
        axisMesh.createBuffers();
        planeMesh = new PlaneMesh();
        planeMesh.createBuffers();
    }

    private function destroyMesh()
    {
        axisMesh.destroyBuffers();
        planeMesh.destroyBuffers();
    }

    private function update(deltaTime: Float, currentTime: Float)
    {
        // setup the model matrix

        modelMatrix.setTranslation(moveVector.x, moveVector.y, moveVector.z);

        // setup the view matrix

        var rad: Float = Math.sin(currentTime * 0.5) * (2 * Math.PI);

        workMatrix.setIdentity();
        workMatrix.rotate(0.0, currentTime, 0.0);
        workMatrix.translate(2.0, 2.0, 2.0);

        var oldOffset: Int = workMatrix.data.offset;

        workMatrix.data.offset = 3 * DataTypeUtils.dataTypeByteSize(DataType.DataTypeFloat32);
        var cx: Float = workMatrix.data.readFloat(DataType.DataTypeFloat32);
        workMatrix.data.offset = 7 * DataTypeUtils.dataTypeByteSize(DataType.DataTypeFloat32);
        var cy: Float = workMatrix.data.readFloat(DataType.DataTypeFloat32);
        workMatrix.data.offset = 11 * DataTypeUtils.dataTypeByteSize(DataType.DataTypeFloat32);
        var cz: Float = workMatrix.data.readFloat(DataType.DataTypeFloat32);

        workMatrix.data.offset = oldOffset;

        var cameraPosition: Vector3 = new Vector3();
        cameraPosition.setXYZ(cx, cy, cz);

        var center: Vector3 = new Vector3();
        center.set(moveVector); // Same as model Matrix transform

        var up: Vector3 = new Vector3();
        up.setXYZ(0.0, 1.0, 0.0);

        viewMatrix.setLookAt(cameraPosition, center, up);

        // setup the Model-View-Projection matrix

        workMatrix.set(modelMatrix);
        workMatrix.multiply(viewMatrix);
        workMatrix.multiply(projection);
    }

    override private function render()
    {
        update(DuellKit.instance().frameDelta, DuellKit.instance().time);

        GL.clear(GLDefines.COLOR_BUFFER_BIT | GLDefines.DEPTH_BUFFER_BIT);

        GL.useProgram(textureShader.shaderProgram);

        // bind the MVP matrix

        GL.uniformMatrix4fv(textureShader.uniformLocations[0], 1, false, workMatrix.data);

        // draw the plane

        planeMesh.bindMesh();

        planeMesh.draw();

        planeMesh.unbindMesh();

        // draw the axis meshes

        axisMesh.bindMesh();

        axisMesh.draw();

        // setup the model matrix for the rotating mesh

        workMatrix.setIdentity();
        workMatrix.translate(0.0, 0.0, -2.0);
        workMatrix.rotate(0.0, DuellKit.instance().time * 2, 0.0);

        modelMatrix.set(workMatrix);

        // resetup the Model-View-Projection matrix

        workMatrix.set(modelMatrix);
        workMatrix.multiply(viewMatrix);
        workMatrix.multiply(projection);

        // rebind the MVP matrix

        GL.uniformMatrix4fv(textureShader.uniformLocations[0], 1, false, workMatrix.data);

        axisMesh.draw();

        axisMesh.unbindMesh();

        GL.bindTexture(GLDefines.TEXTURE_2D, GL.nullTexture);

        GL.useProgram(GL.nullProgram);
    }
}
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

import duell.DuellKit;
import gl.GL;
import gl.GLDefines;
import types.Data;
import types.Vector3;
import types.Matrix3;
import types.Matrix3Matrix4Tools;
import types.Matrix4;
import types.Matrix4Tools;
import tests.directionalLightTest.PlaneMesh;
import tests.projectionTest.AxisMesh;
import tests.utils.AssetLoader;
import tests.utils.Shader;

using types.Matrix4Tools;
using types.Matrix3Tools;
using types.Matrix3Matrix4Tools;
using types.Matrix3DataTools;

class DirectionalLightTest extends OpenGLTest
{
    inline private static var LIGHT_VERTEXSHADER_PATH = "common/shaders/DirectionalLight_PosColorNormal.vsh";
    inline private static var LIGHT_FRAGMENTSHADER_PATH = "common/shaders/Base_ColorLight.fsh";

    inline private static var BASE_VERTEXSHADER_PATH = "common/shaders/Base_PosColor.vsh";
    inline private static var BASE_FRAGMENTSHADER_PATH = "common/shaders/Base_Color.fsh";

    inline static private var floatSize: Int = 4;
    inline static private var matrix3Size: Int = 9;

    private var lightingShader: Shader;
    private var baseShader: Shader;

    private var cubeMesh: CubeMesh;
    private var axisMesh: AxisMesh;
    private var planeMesh: PlaneMesh;

    private var normalMatrix3: Matrix3;

    private var normalMatrix3Data: Data;

    private var ambientColor: Vector3;
    private var lightColor: Vector3;
    private var lightDirection: Vector3;
    private var lightPosition: Vector3;

    private var cameraPosition: Vector3;
    private var zeroPosition: Vector3;
    private var upDirection: Vector3;

    private var modelMatrix: Matrix4;
    private var viewMatrix: Matrix4;
    private var projection: Matrix4;

    private var mvpPlane: Matrix4;
    private var mvpCube: Matrix4;
    private var mvpAxis: Matrix4;

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

        normalMatrix3Data = new Data(matrix3Size * floatSize);

        normalMatrix3 = new Matrix3();

        ambientColor = new Vector3();
        ambientColor.setXYZ(0.0, 0.0, 0.0);

        lightColor = new Vector3();
        lightColor.setXYZ(1.0, 1.0, 1.0);

        lightDirection = new Vector3();

        lightPosition = new Vector3();
        lightPosition.setXYZ(0.0, 0.0, 2.0);

        cameraPosition = new Vector3();
        cameraPosition.setXYZ(4.0, 4.0, 4.0);

        zeroPosition = new Vector3();

        upDirection = new Vector3();
        upDirection.z = 1.0;

        modelMatrix = new Matrix4();
        modelMatrix.setIdentity();

        viewMatrix = new Matrix4();
        viewMatrix.setIdentity();

        var aspect: Float = DuellKit.instance().screenWidth / DuellKit.instance().screenHeight;

        projection = new Matrix4();
        projection.setPerspectiveFov(Math.PI * 0.3, aspect, 0.1, 2000.0);

        mvpPlane = new Matrix4();
        mvpCube = new Matrix4();
        mvpAxis = new Matrix4();
    }

    private function createShader()
    {
        var lightVertexShader: String = AssetLoader.getStringFromFile(LIGHT_VERTEXSHADER_PATH);
        var lightFragmentShader: String = AssetLoader.getStringFromFile(LIGHT_FRAGMENTSHADER_PATH);
        var baseVertexShader: String = AssetLoader.getStringFromFile(BASE_VERTEXSHADER_PATH);
        var baseFragmentShader: String = AssetLoader.getStringFromFile(BASE_FRAGMENTSHADER_PATH);

        var LightAttributes: Array<String> = ["a_Position", "a_Color", "a_Normal"];
        var LightUniforms: Array<String> = ["u_MVPMatrix", "u_NormalMatrix", "u_AmbientColorVector", "u_LightColorVector", "u_LightDirection"];
        var baseAttributes: Array<String> = ["a_Position", "a_Color"];
        var baseUniforms: Array<String> = ["u_MVPMatrix"];

        lightingShader = new Shader();
        lightingShader.createShader(lightVertexShader, lightFragmentShader, LightAttributes, LightUniforms);
        baseShader = new Shader();
        baseShader.createShader(baseVertexShader, baseFragmentShader, baseAttributes, baseUniforms);
    }

    private function destroyShader(): Void
    {
        lightingShader.destroyShader();
        baseShader.destroyShader();
    }

    private function createMesh()
    {
        cubeMesh = new CubeMesh();
        cubeMesh.createBuffers();
        axisMesh = new AxisMesh();
        axisMesh.createBuffers();
        planeMesh = new PlaneMesh();
        planeMesh.createBuffers();
    }

    private function destroyMesh()
    {
        cubeMesh.destroyBuffers();
        axisMesh.destroyBuffers();
        planeMesh.destroyBuffers();
    }

    private function update(deltaTime: Float, currentTime: Float)
    {
        // setup light

        lightPosition.x = Math.sin(currentTime) * 2;
        lightPosition.y = Math.cos(currentTime) * 2;
        lightPosition.z = Math.sin(currentTime) + 1;

        lightDirection.set(lightPosition);

        // setup MVP for Cube Mesh

        modelMatrix.setIdentity();

        normalMatrix3.writeMatrix4IntoMatrix3(modelMatrix);
        normalMatrix3.inverse();

        viewMatrix.setLookAt(cameraPosition, zeroPosition, upDirection);

        mvpCube.set(modelMatrix);
        mvpCube.multiply(viewMatrix);
        mvpCube.multiply(projection);

        // setup MVP for Plane Mesh

        modelMatrix.setTranslation(0.0, 0.0, -0.5);

        mvpPlane.set(modelMatrix);
        mvpPlane.multiply(viewMatrix);
        mvpPlane.multiply(projection);

        // setup MVP for Axis Mesh

        modelMatrix.setLookAt(lightPosition, zeroPosition, upDirection);
        modelMatrix.inverse();

        mvpAxis.set(modelMatrix);
        mvpAxis.multiply(viewMatrix);
        mvpAxis.multiply(projection);
    }

    override private function render()
    {
        update(DuellKit.instance().frameDelta, DuellKit.instance().time);

        GL.clear(GLDefines.COLOR_BUFFER_BIT | GLDefines.DEPTH_BUFFER_BIT);

        GL.useProgram(lightingShader.shaderProgram);

        ambientColor.data.offset = 0;
        lightColor.data.offset = 0;
        lightDirection.data.offset = 0;

        GL.uniformMatrix4fv(lightingShader.uniformLocations[0], 1, false, mvpCube.data);

        normalMatrix3.writeMatrix3IntoData(normalMatrix3Data);
        GL.uniformMatrix3fv(lightingShader.uniformLocations[1], 1, false, normalMatrix3Data);

        GL.uniform3fv(lightingShader.uniformLocations[2], 1, ambientColor.data);
        GL.uniform3fv(lightingShader.uniformLocations[3], 1, lightColor.data);
        GL.uniform3fv(lightingShader.uniformLocations[4], 1, lightDirection.data);

        cubeMesh.bindMesh();

        cubeMesh.draw();

        cubeMesh.unbindMesh();

        GL.uniformMatrix4fv(lightingShader.uniformLocations[0], 1, false, mvpPlane.data);

        planeMesh.bindMesh();

        planeMesh.draw();

        planeMesh.unbindMesh();

        GL.bindTexture(GLDefines.TEXTURE_2D, GL.nullTexture);

        GL.useProgram(baseShader.shaderProgram);

        GL.uniformMatrix4fv(baseShader.uniformLocations[0], 1, false, mvpAxis.data);

        axisMesh.bindMesh();

        axisMesh.draw();

        axisMesh.unbindMesh();

        GL.useProgram(GL.nullProgram);
    }
}
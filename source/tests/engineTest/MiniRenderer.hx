package tests.engineTest;

import types.Color4F;
import gl.GL;
import gl.GLDefines;
import tests.utils.Shader;
import types.Data;
import tests.utils.Bitmap;
import tests.utils.ImageDecoder;
import tests.utils.AssetLoader;

class MiniRenderer
{
    inline private static var IMAGE_PATH = "meshTest/images/lena.png";
    inline private static var VERTEXSHADER_PATH = "common/shaders/ScreenSpace_PosColorTex.vsh";
    inline private static var FRAGMENTSHADER_PATH = "common/shaders/ScreenSpace_PosColorTex.fsh";

    private var textureShader: Shader;
    private var texture: GLTexture;

    private var engine: MiniEngine;

    public function new(engine: MiniEngine)
    {
        this.engine = engine;
    }

    public function init()
    {
        createShader();
        createTexture();
    }

    public function deinit()
    {
        destroyTexture();
        destroyShader();
    }

    public function prepareGameObject(gameObject: GameObject)
    {
        if (gameObject.mesh != null)
        {
            gameObject.mesh.createBuffers();
        }
    }

    public function cleanUpGameObject(gameObject: GameObject)
    {
        if (gameObject.mesh != null)
        {
            gameObject.mesh.destroyBuffers();
        }
    }

    private function createShader()
    {
        var vertexShader: String = AssetLoader.getStringFromFile(VERTEXSHADER_PATH);
        var fragmentShader: String = AssetLoader.getStringFromFile(FRAGMENTSHADER_PATH);

        textureShader = new Shader();
        textureShader.createShader(vertexShader, fragmentShader, ["a_Position", "a_Color", "a_TexCoord"], ["u_Tint", "s_Texture"]);
    }

    private function destroyShader(): Void
    {
        textureShader.destroyShader();
    }

    private function createTexture(): Void
    {
        var imageData: Data = AssetLoader.getDataFromFile(IMAGE_PATH);
        var bitmap: Bitmap = ImageDecoder.decodePNG(imageData);

        /// Create, configure and upload opengl texture

        texture = GL.createTexture();

        GL.bindTexture(GLDefines.TEXTURE_2D, texture);

        // Configure Filtering Mode
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_MAG_FILTER, GLDefines.NEAREST);
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_MIN_FILTER, GLDefines.NEAREST);

        // Configure wrapping
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_WRAP_S, GLDefines.REPEAT);
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_WRAP_T, GLDefines.REPEAT);

        // Copy data to gpu memory
        switch (bitmap.components)
        {
            case 3:
                {
                    GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 2);
                    GL.texImage2D(GLDefines.TEXTURE_2D, 0, GLDefines.RGB, bitmap.width, bitmap.height, 0, GLDefines.RGB, GLDefines.UNSIGNED_SHORT_5_6_5, bitmap.data);
                }
            case 4:
                {
                    GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 4);
                    GL.texImage2D(GLDefines.TEXTURE_2D, 0, GLDefines.RGBA, bitmap.width, bitmap.height, 0, GLDefines.RGBA, GLDefines.UNSIGNED_BYTE, bitmap.data);
                }
            case 1:
                {
                    GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 1);
                    GL.texImage2D(GLDefines.TEXTURE_2D, 0, GLDefines.ALPHA, bitmap.width, bitmap.height, 0, GLDefines.ALPHA, GLDefines.UNSIGNED_BYTE, bitmap.data);
                }
            default: throw("Unsupported number of components");
        }

        GL.bindTexture(GLDefines.TEXTURE_2D, GL.nullTexture);
    }

    private function destroyTexture(): Void
    {
        GL.deleteTexture(texture);
    }

    private function updateMeshes()
    {
        for (gameObject in engine.gameObjects)
        {
            if (gameObject.mesh != null)
            {
                gameObject.mesh.updateBuffers();
            }
        }
    }

    public function render()
    {
        updateMeshes();

        var bgColor: Color4F = engine.backgroundColor;
        GL.clearColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a);
        GL.clear(GLDefines.COLOR_BUFFER_BIT);

        GL.useProgram(textureShader.shaderProgram);

        GL.uniform4f(textureShader.uniformLocations[0], 1.0, 1.0, 1.0, 1.0);

        GL.activeTexture(GLDefines.TEXTURE0);
        GL.bindTexture(GLDefines.TEXTURE_2D, texture);

        for (gameObject in engine.gameObjects)
        {
            if (gameObject.mesh != null)
            {
                gameObject.mesh.bindMesh();
                gameObject.mesh.draw();
                gameObject.mesh.unbindMesh();
            }
        }

        GL.bindTexture(GLDefines.TEXTURE_2D, GL.nullTexture);
        GL.useProgram(GL.nullProgram);
    }
}

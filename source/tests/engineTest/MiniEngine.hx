package tests.engineTest;

import types.Color4F;

class MiniEngine
{
    public var backgroundColor(default, null): Color4F;

    public var gameObjects(default, null): Array<GameObject>;

    private var renderer: MiniRenderer;

    public function new()
    {
        backgroundColor = new Color4F();
        gameObjects = new Array();
        renderer = new MiniRenderer(this);
    }

    public function init()
    {
        renderer.init();
    }

    public function deinit()
    {
        renderer.deinit();
    }

    public function add(gameObject: GameObject)
    {
        gameObjects.push(gameObject);
        renderer.prepareGameObject(gameObject);
    }

    public function remove(gameObject: GameObject)
    {
        renderer.cleanUpGameObject(gameObject);
        gameObjects.remove(gameObject);
    }

    public function processEvents()
    {
        // TODO
    }

    public function update(deltaTime: Float, currentTime: Float)
    {
        var index: Int = 0;

        for (gameObject in gameObjects)
        {
            ++index;

            if (gameObject.mesh != null)
            {
                gameObject.mesh.x = gameObject.x;
                gameObject.mesh.y = gameObject.y;

                var tween = (Math.sin(currentTime * 0.5 * index) + 1.0) / 2.0;

                gameObject.mesh.width = 0.75 + 0.25 * tween;
                gameObject.mesh.height = 1.0 - 0.25 * tween;

                gameObject.mesh.uMultiplier = 1.0 + Math.sin(currentTime * 0.125);
                gameObject.mesh.vMultiplier = 1.0 + Math.cos(currentTime * 0.125);
            }
        }
    }

    public function render()
    {
        renderer.render();
    }
}

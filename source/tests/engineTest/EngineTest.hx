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

package tests.engineTest;

import duellkit.DuellKit;

class EngineTest extends OpenGLTest
{
    private var miniEngine: MiniEngine;

    override private function onCreate(): Void
    {
        super.onCreate();

        miniEngine = new MiniEngine();
        miniEngine.init();

        miniEngine.backgroundColor.setRGBA(0.0, 1.0, 1.0, 1.0);

        createAndAddGameObjects();
    }

    private function createAndAddGameObjects()
    {
        var leftBar: GameObject = new GameObject();
        var rightBar: GameObject = new GameObject();
        var ball: GameObject = new GameObject();

        leftBar.mesh = new AnimatedMesh();
        rightBar.mesh = new AnimatedMesh();
        ball.mesh = new AnimatedMesh();

        leftBar.x = -1.0;
        leftBar.y = 0.0;
        leftBar.imageName = "CoolPic.png";

        rightBar.x = 0.5;
        rightBar.y = 0.0;

        ball.x = 0.0;
        ball.y = 0.0;

        miniEngine.add(leftBar);
        miniEngine.add(rightBar);
        miniEngine.add(ball);
    }

    // Destroy your created OpenGL objectes
    override public function onDestroy(): Void
    {
        miniEngine.deinit();
        super.onDestroy();
    }

    override private function render()
    {
        miniEngine.processEvents();  //  (like input or messages)

        miniEngine.update(DuellKit.instance().frameDelta, DuellKit.instance().time);

        miniEngine.render();
    }
}
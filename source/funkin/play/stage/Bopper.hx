package funkin.play.stage;

import flixel.FlxSprite;
import funkin.modding.IScriptedClass.IPlayStateScriptedClass;
import funkin.modding.events.ScriptEvent;

/**
 * A Bopper is a stage prop which plays a dance animation.
 * Y'know, a thingie that bops. A bopper.
 */
class Bopper extends FlxSprite implements IPlayStateScriptedClass
{
	/**
	 * The bopper plays the dance animation once every `danceEvery` beats.
	 * Set to 0 to disable idle animation.
	 */
	public var danceEvery:Int = 1;

	/**
	 * Whether the bopper should dance left and right.
	 * - If true, alternate playing `danceLeft` and `danceRight`.
	 * - If false, play `idle` every time.
	 * 
	 * You can manually set this value, or you can leave it as `null` to determine it automatically.
	 */
	public var shouldAlternate:Null<Bool> = null;

	/**
	 * Offset the character's sprite by this much when playing each animation.
	 */
	public var animationOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();

	/**
	 * Add a suffix to the `idle` animation (or `danceLeft` and `danceRight` animations)
	 * that this bopper will play.
	 */
	public var idleSuffix(default, set):String = "";

	function set_idleSuffix(value:String):String
	{
		this.idleSuffix = value;
		this.dance();
		return value;
	}

	/**
	 * The offset of the character relative to the position specified by the stage.
	 */
	public var globalOffsets(default, null):Array<Float> = [0, 0];

	private var animOffsets(default, set):Array<Float> = [0, 0];

	function set_animOffsets(value:Array<Float>)
	{
		if (animOffsets == null)
			animOffsets = [0, 0];
		if (animOffsets == value)
			return value;

		var xDiff = animOffsets[0] - value[0];
		var yDiff = animOffsets[1] - value[1];

		this.x += xDiff;
		this.y += yDiff;

		return animOffsets = value;
	}

	/**
	 * Whether to play `danceRight` next iteration.
	 * Only used when `shouldAlternate` is true.
	 */
	var hasDanced:Bool = false;

	public function new(danceEvery:Int = 1)
	{
		super();
		this.danceEvery = danceEvery;
	}

	function update_shouldAlternate():Void
	{
		if (hasAnimation('danceLeft'))
		{
			this.shouldAlternate = true;
		}
	}

	/**
	 * Called once every beat of the song.
	 */
	public function onBeatHit(event:SongTimeScriptEvent):Void
	{
		if (danceEvery > 0 && event.beat % danceEvery == 0)
		{
			dance(true);
		}
	}

	/**
	 * Called every `danceEvery` beats of the song.
	 */
	public function dance(force:Bool = false):Void
	{
		if (this.animation == null)
		{
			return;
		}

		if (shouldAlternate == null)
		{
			update_shouldAlternate();
		}

		if (shouldAlternate)
		{
			if (hasDanced)
			{
				playAnimation('danceRight$idleSuffix', true);
			}
			else
			{
				playAnimation('danceLeft$idleSuffix', true);
			}
			hasDanced = !hasDanced;
		}
		else
		{
			playAnimation('idle$idleSuffix', true);
		}
	}

	public function hasAnimation(id:String):Bool
	{
		if (this.animation == null)
			return false;

		return this.animation.getByName(id) != null;
	}

	/**
	 * Ensure that a given animation exists before playing it.
	 * Will gracefully check for name, then name with stripped suffixes, then 'idle', then fail to play.
	 * @param name 
	 */
	function correctAnimationName(name:String)
	{
		// If the animation exists, we're good.
		if (hasAnimation(name))
			return name;

		trace('[BOPPER] Animation "$name" does not exist!');

		// Attempt to strip a `-alt` suffix, if it exists.
		if (name.lastIndexOf('-') != -1)
		{
			var correctName = name.substring(0, name.lastIndexOf('-'));
			trace('[BOPPER] Attempting to fallback to "$correctName"');
			return correctAnimationName(correctName);
		}
		else
		{
			if (name != 'idle')
			{
				trace('[BOPPER] Attempting to fallback to "idle"');
				return correctAnimationName('idle');
			}
			else
			{
				trace('[BOPPER] Failing animation playback.');
				return null;
			}
		}
	}

	/**
	 * @param name The name of the animation to play.
	 * @param restart Whether to restart the animation if it is already playing.
	 */
	public function playAnimation(name:String, restart:Bool = false):Void
	{
		var correctName = correctAnimationName(name);
		if (correctName == null)
			return;

		this.animation.play(correctName, restart, false, 0);

		applyAnimationOffsets(correctName);
	}

	function applyAnimationOffsets(name:String)
	{
		var offsets = animationOffsets.get(name);
		if (offsets != null)
		{
			this.animOffsets = [offsets[0] + globalOffsets[0], offsets[1] + globalOffsets[1]];
		}
		else
		{
			this.animOffsets = globalOffsets;
		}
	}

	public function isAnimationFinished():Bool
	{
		return this.animation.finished;
	}

	public function setAnimationOffsets(name:String, xOffset:Float, yOffset:Float):Void
	{
		animationOffsets.set(name, [xOffset, yOffset]);
	}

	/**
	 * Returns the name of the animation that is currently playing.
	 * If no animation is playing (usually this means the character is BROKEN!),
	 *   returns an empty string to prevent NPEs.
	 */
	public function getCurrentAnimation():String
	{
		if (this.animation == null || this.animation.curAnim == null)
			return "";
		return this.animation.curAnim.name;
	}

	public function onScriptEvent(event:ScriptEvent) {}

	public function onCreate(event:ScriptEvent) {}

	public function onDestroy(event:ScriptEvent) {}

	public function onUpdate(event:UpdateScriptEvent) {}

	public function onPause(event:PauseScriptEvent) {}

	public function onResume(event:ScriptEvent) {}

	public function onSongStart(event:ScriptEvent) {}

	public function onSongEnd(event:ScriptEvent) {}

	public function onGameOver(event:ScriptEvent) {}

	public function onNoteHit(event:NoteScriptEvent) {}

	public function onNoteMiss(event:NoteScriptEvent) {}

	public function onNoteGhostMiss(event:GhostMissNoteScriptEvent) {}

	public function onStepHit(event:SongTimeScriptEvent) {}

	public function onCountdownStart(event:CountdownScriptEvent) {}

	public function onCountdownStep(event:CountdownScriptEvent) {}

	public function onCountdownEnd(event:CountdownScriptEvent) {}

	public function onSongLoaded(eent:SongLoadScriptEvent) {}

	public function onSongRetry(event:ScriptEvent) {}
}
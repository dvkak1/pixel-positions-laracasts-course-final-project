@props(['job'])

<x-panel class="flex gap-x-6">
    <div>
        <x-employer-logo />
    </div>
    <div class="flex-1 flex flex-col">
          <a href="#" class="self-start text-sm text-gray-700">{{ $job->employer->name }}</a>

            <h3 class="font-bold text-xl mt-3 group-hover:text-blue-800 transition-colors duration-300">{{ $job->title }}</h3>

            <p class="text-sm text-gray-400 mt-auto">{{ $job->salary }}</p>
    </div>

            <div>
                    @foreach($job->tags AS $tag)
                        <x-tag :$tag />
                    @endforeach
            </div>

            <!--
                Due to placehold.it being deprecated, replace with placehold.co
                Be mindful of where you place the </div> to adjust layouts accordingly.
            -->

</x-panel>


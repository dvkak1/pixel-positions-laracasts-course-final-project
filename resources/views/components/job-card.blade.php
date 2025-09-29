@props(['job'])

<x-panel class="flex flex-col text-center">
          <div class="self-start text-sm">
            {{ $job->employer->name }}
          </div>

          <div class="py-8 font-bold">
            <h3 class="group-hover:text-blue-600 text-xl font-bold transition-colors duration-300">
                <a href="{{ $job->url }}"  target="_blank">
                    {{ $job->title }}
                </a>
            </h3>
            <p class="text-sm mt-4">{{ $job->salary }}</p>
          </div>

            <div class="flex justify-between items-center mt-auto">
                <div class="space-x-2">
                    @foreach($job->tags AS $tag)
                          <x-tag :$tag size="small" />
                    @endforeach
                </div>

            <!--
                Due to placehold.it being deprecated, replace with placehold.co
                Be mindful of where you place the </div> to adjust layouts accordingly.
            -->
            <x-employer-logo :employer="$job->employer" :width="42"/>
          </div>
    </x-panel>



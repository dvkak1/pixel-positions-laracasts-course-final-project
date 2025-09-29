<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Tag;
use App\Models\Job;

class TagController extends Controller
{
    public function __invoke(Tag $tag)
    {
        //jobs for this tag
        $jobs = $tag->jobs()->get(); //Not included in Jeff Way's code but this eager loads the jobs

         return view(view: 'results', data: ['jobs' => $tag->jobs]);

    }
}

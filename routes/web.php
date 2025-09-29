<?php
use App\Http\Controllers\JobController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\RegisteredUserController;
use App\Http\Controllers\SessionController;
use App\Http\Controllers\SearchController;

Route::get('/', [JobController::class, 'index']);
Route::get('/search', SearchController::class);

//Always make sure that there is one get and post route for registration forms
//Use middleware to implement authorization.
Route::middleware('guest')->group(function() {
    Route::get('/register', [RegisteredUserController::class, 'create']);
    Route::post('/register', [RegisteredUserController::class, 'store']);

    Route::get('login', [SessionController::class, 'create']);
    Route::post('login', [SessionController::class, 'store']);
});



Route::post('logout', [SessionController::class, 'destroy'])->middleware('auth');

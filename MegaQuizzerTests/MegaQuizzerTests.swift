//
//  MegaQuizzerTests.swift
//  MegaQuizzerTests
//
//  Created by slava on 16.10.2021.
//

import XCTest
@testable import MegaQuizzer

class MegaQuizzerTests: XCTestCase {
    var sut: QuizesListViewController!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = QuizesListViewController()
        
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    
    func testQuizzesArrayCountQualsTableViewCellsCount() throws {
        // given
        sut.quizzes = [Quiz(name: "test", questions: [QuestionCard(questionText: "", answers: [Answer(answerText: "", isTrue: true)])]), Quiz(name: "test2", questions: [QuestionCard(questionText: "", answers: [Answer(answerText: "", isTrue: true)])])]
        let quizArrayCount = sut.quizzes.count
        
        // when
        let numberOfRows = sut.tableView.numberOfRows(inSection: 0)
        sut.tableView.reloadData()
        
        // then
        XCTAssertEqual(quizArrayCount, numberOfRows)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
